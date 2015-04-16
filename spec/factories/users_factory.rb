FactoryGirl.define do

  factory :user do
    sequence(:email) {|n| "test#{n}@localhost.test.lan" }
    password 'test-password'
    sequence(:username) {|n| "#{FFaker::Internet.user_name}#{n}" }
  end

end
