# == Schema Information
#
# Table name: webhooks
#
#  id             :integer          not null, primary key
#  namespace_id   :integer
#  url            :string(255)
#  username       :string(255)
#  password       :string(255)
#  request_method :integer
#  content_type   :integer
#  enabled        :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_webhooks_on_namespace_id  (namespace_id)
#

class Webhook < ActiveRecord::Base
  include PublicActivity::Common

  enum request_method: ["GET", "POST"]
  enum content_type: ["application/json", "application/x-www-form-urlencoded"]

  belongs_to :namespace

  has_many :deliveries, class_name: "WebhookDelivery"
  has_many :headers, class_name: "WebhookHeader"

  validates :url, presence: true

  before_destroy :update_activities!

  private

  def update_activities!
    PublicActivity::Activity.where(trackable: self).update_all(
      parameters: {
        namespace_id:   namespace.id,
        namespace_name: namespace.clean_name,
        webhook_url:    url
      }
    )
  end
end
