FactoryGirl.define do
  factory :comment do
    sequence :body do |b|
      "a short comment #{b}"
    end

    association :author, factory: :user
  end
end
