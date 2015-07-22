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
