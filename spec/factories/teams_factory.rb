FactoryGirl.define do

  factory :team do
    name { FFaker::NatoAlphabet.code }
    association :owner, factory: :user
  end

end
