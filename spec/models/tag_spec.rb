# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)      default("latest"), not null
#  repository_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#  digest        :string(255)
#
# Indexes
#
#  index_tags_on_name_and_repository_id  (name,repository_id) UNIQUE
#  index_tags_on_repository_id           (repository_id)
#  index_tags_on_user_id                 (user_id)
#

require "rails_helper"

describe Tag do
  it { should belong_to(:repository) }
end
