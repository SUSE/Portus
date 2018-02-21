# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id              :integer          not null, primary key
#  name            :string(255)      default("latest"), not null
#  repository_id   :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  digest          :string(255)
#  image_id        :string(255)      default("")
#  marked          :boolean          default(FALSE)
#  username        :string(255)
#  scanned         :integer          default(0)
#  vulnerabilities :text(16777215)
#
# Indexes
#
#  index_tags_on_repository_id  (repository_id)
#  index_tags_on_user_id        (user_id)
#

require "rails_helper"

describe TagsController, type: :controller do
  let(:valid_session) { {} }

  describe "GET #show" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag)        { create(:tag, name: "tag0", repository: repository) }

    before do
      sign_in user
      request.env["HTTP_REFERER"] = "/"

      enable_security_vulns_module!
    end

    it "assigns the requested tag as @tag" do
      get :show, { id: tag.to_param }, valid_session
      expect(assigns(:tag)).to eq(tag)
      expect(response.status).to eq 200
    end

    it "assigns the tag's vulnerabilities as @vulnerabilities" do
      allow_any_instance_of(Tag).to receive(:fetch_vulnerabilities)
        .and_return(["something"])
      get :show, { id: tag.to_param }, valid_session
      expect(assigns(:vulnerabilities)).to eq(["something"])
      expect(response.status).to eq 200
    end
  end
end
