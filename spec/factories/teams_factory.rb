# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "team_name#{n}" }
    owners { |t| [t.association(:user)] }
  end
end
