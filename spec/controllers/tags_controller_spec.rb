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
#
# Indexes
#
#  index_tags_on_name_and_repository_id  (name,repository_id) UNIQUE
#  index_tags_on_repository_id           (repository_id)
#  index_tags_on_user_id                 (user_id)
#

require "rails_helper"

describe TagsController, type: :controller do
  let(:valid_session) { {} }

  describe "GET #show" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag)        { create(:tag, name: "tag0", repository: repository) }

    before :each do
      sign_in user
      request.env["HTTP_REFERER"] = "/"

      enable_security_vulns_module!
    end

    it "assigns the requested tag as @tag" do
      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities)
        .and_return([])
      get :show, { id: tag.to_param }, valid_session
      expect(assigns(:tag)).to eq(tag)
      expect(response.status).to eq 200
    end

    it "assigns the tag's vulnerabilities as @vulnerabilities" do
      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities)
        .and_return(["something"])
      get :show, { id: tag.to_param }, valid_session
      expect(assigns(:vulnerabilities)).to eq(["something"])
      expect(response.status).to eq 200
    end
  end

  describe "DELETE #destroy" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag)        { create(:tag, name: "tag", repository: repository) }

    before :each do
      sign_in user
      request.env["HTTP_REFERER"] = "/"
      APP_CONFIG["delete"] = { "enabled" => true }
    end

    it "removes a tag" do
      allow_any_instance_of(Tag).to receive(:delete_by_digest!).and_return(true)
      delete :destroy, { id: tag.id }, valid_session
      expect(response.status).to eq 200
    end

    it "also removes the repo if there are no more tags" do
      allow_any_instance_of(Tag).to receive(:delete_by_digest!) do
        Tag.destroy_all
      end

      delete :destroy, { id: tag.id }, valid_session
      expect(flash[:notice]).to eq "Repository removed with all its tags"
      expect(response.status).to eq 200
    end

    it "responds accordingly on error" do
      allow_any_instance_of(Tag).to receive(:delete_by_digest!).and_return(false)

      delete :destroy, { id: tag.id }, valid_session
      expect(response.status).to eq 500
    end

    it "raises the proper exception when a tag cannot be found" do
      expect do
        delete :destroy, { id: -1 }, valid_session
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns a 403 if deletes are not enabled" do
      APP_CONFIG["delete"] = { "enabled" => false }
      delete :destroy, { id: -1 }, valid_session
      expect(response.status).to eq 403
    end
  end
end
