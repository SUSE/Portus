FactoryGirl.define do
  factory :image do
    sequence :name do |n|
      "image#{n}"
    end
  end
end
