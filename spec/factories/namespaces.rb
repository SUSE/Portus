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
#  registry_id :integer
#  global      :boolean          default("0")
#
# Indexes
#
#  fulltext_index_namespaces_on_name         (name)
#  index_namespaces_on_name_and_registry_id  (name,registry_id) UNIQUE
#  index_namespaces_on_registry_id           (registry_id)
#  index_namespaces_on_team_id               (team_id)
#

FactoryGirl.define do
  factory :namespace do
    sequence :name do |n|
      "namespace#{n}"
    end

    registry { association(:registry) }
  end
end
