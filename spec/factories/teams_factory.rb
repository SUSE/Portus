FactoryGirl.define do

  factory :team do
    name   { FFaker::NatoAlphabet.code.downcase }
    owners {|t| [t.association(:user)] }
  end

end
