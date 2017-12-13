# frozen_string_literal: true

FactoryGirl.define do
  factory :tag do
    sequence :name do |n|
      "tag#{n}"
    end
    repository
  end
end
