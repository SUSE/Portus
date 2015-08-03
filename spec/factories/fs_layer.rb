FactoryGirl.define do
  factory :fs_layer do
    sequence :blob_sum do |n|
      "fs_layera sum: #{n}"
    end
    tag
  end
end
