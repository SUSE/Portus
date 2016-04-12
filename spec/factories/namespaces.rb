# == Schema Information
#
# Table name: namespaces
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer
#  public      :boolean          default("0")
#  registry_id :integer          not null
#  global      :boolean          default("0")
#  description :text(65535)
#

FactoryGirl.define do
  factory :namespace do
    sequence :name do |n|
      "namespace#{n}"
    end

    registry { association(:registry) }
  end
end
