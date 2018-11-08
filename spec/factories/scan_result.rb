# frozen_string_literal: true

FactoryBot.define do
  factory :scan_result do
    tag
    vulnerability
  end
end
