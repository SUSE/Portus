FactoryGirl.define do
  factory :namespace do
    sequence :name do |n|
      "namespace#{n}"
    end
  end
end
