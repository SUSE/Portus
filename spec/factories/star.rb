FactoryGirl.define do
  factory :star do
    repository
    association :author, factory: :user
  end
end
