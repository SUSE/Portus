# frozen_string_literal: true

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
#  image_id      :string(255)      default("")
#  marked        :boolean          default(FALSE)
#  username      :string(255)
#  scanned       :integer          default(0)
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
    let!(:registry)      { create(:registry, hostname: "registry.test.lan") }
    let!(:user)          { create(:admin) }
    let!(:repository)    { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag) do
      create(:tag, name: "tag0", repository: repository, scanned: Tag.statuses[:scan_done])
    end
    let!(:vulnerability) { create(:vulnerability, name: "CVE-1234", scanner: "clair") }
    let!(:scan_result)   { create(:scan_result, tag: tag, vulnerability: vulnerability) }

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
      get :show, { id: tag.to_param }, valid_session
      expect(assigns(:vulnerabilities)["clair"]).to eq([vulnerability])
      expect(response.status).to eq 200
    end
  end
end
