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

require "rails_helper"

RSpec.describe Webhook, type: :model do
  subject { create(:webhook, namespace: create(:namespace)) }
  let!(:request_methods) { ["GET", "POST"] }
  let!(:content_types) { ["application/json", "application/x-www-form-urlencoded"] }

  it { should have_many(:headers) }
  it { should have_many(:deliveries) }
  it { should belong_to(:namespace) }

  it { should validate_presence_of(:url) }
  it { should define_enum_for(:request_method) }
  it { should allow_value(*request_methods).for(:request_method) }
  it { should define_enum_for(:content_type) }
  it { should allow_value(*content_types).for(:content_type) }
end
