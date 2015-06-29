FactoryGirl.define do
  factory :namespace do
    sequence :name do |n|
      "namespace#{n}"
    end

    registry { association(:registry) }
  end
end
