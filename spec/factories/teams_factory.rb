FactoryGirl.define do

  factory :team do
    name { FFaker::NatoAlphabet.code.downcase }
    association :owner, factory: :user
  end

end
