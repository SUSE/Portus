# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@localhost.test.lan" }
    password { "test-password" }
    sequence(:username) { |n| "username#{n}" }
    bot { false }

    factory :admin do
      admin { true }
    end
  end
end
