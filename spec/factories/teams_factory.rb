FactoryGirl.define do

  factory :team do
    name { FFaker::NatoAlphabet.code.downcase }
  end

end
