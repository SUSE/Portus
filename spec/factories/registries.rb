FactoryGirl.define do
  factory :registry do
    before(:create) { create(:admin) }

    sequence :hostname do |n|
      "registry hostname #{n}"
    end

    sequence :name do |n|
      "registry name #{n}"
    end

    use_ssl false
  end
end
