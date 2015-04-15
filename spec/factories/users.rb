FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "test#{n}@localhost.test.lan"
    end
    password "test-password"
  end

end
