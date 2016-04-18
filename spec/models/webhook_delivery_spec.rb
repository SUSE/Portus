# == Schema Information
#
# Table name: webhook_deliveries
#
#  id              :integer          not null, primary key
#  webhook_id      :integer
#  uuid            :string(255)
#  status          :string(255)
#  request_header  :text(65535)
#  request_body    :text(65535)
#  response_header :text(65535)
#  response_body   :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_webhook_deliveries_on_webhook_id           (webhook_id)
#  index_webhook_deliveries_on_webhook_id_and_uuid  (webhook_id,uuid) UNIQUE
#

require "rails_helper"

RSpec.describe WebhookDelivery, type: :model do
  subject { create(:webhook_delivery, webhook: create(:webhook)) }

  it { should belong_to(:webhook) }
  it { should validate_uniqueness_of(:uuid).scoped_to(:webhook_id) }
end
