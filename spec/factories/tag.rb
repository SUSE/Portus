# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence :name do |n|
      "tag#{n}"
    end
    repository
  end
end
