FactoryGirl.define do
  factory :repository do
    sequence :name do |n|
      "repository#{n}"
    end
  end
end
