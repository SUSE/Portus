FactoryGirl.define do
  factory :tag do
    sequence :name do |n|
      "tag#{n}"
    end
    architecture { 'amd64' }
    repository
  end
end
