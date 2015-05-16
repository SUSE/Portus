FactoryGirl.define do
  factory :registry do
    before(:create) { create(:user, admin: true) }
    sequence :hostname do |n|
      "registry hostname #{n}"
    end
    sequence :name do |n|
      "registry name #{n}"
    end
  end
end
