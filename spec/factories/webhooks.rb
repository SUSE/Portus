# frozen_string_literal: true

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
#  enabled        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string(255)      not null
#
# Indexes
#
#  index_webhooks_on_namespace_id  (namespace_id)
#

FactoryBot.define do
  factory :webhook do
    name { "webhook" }
    url { "http://www.example.com" }
    request_method { "POST" }
    content_type { "application/json" }
    enabled { true }
    username { "" }
    password { "" }
  end
end
