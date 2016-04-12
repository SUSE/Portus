# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  namespace_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :repository do
    sequence :name do |n|
      "repository#{n}"
    end

    trait :starred do
      stars { |t| [t.association(:star)] }
    end
  end
end
