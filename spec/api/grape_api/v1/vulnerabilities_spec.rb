# frozen_string_literal: true

require "rails_helper"

describe API::V1::Vulnerabilities, type: :request do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:public_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_public],
           team:       create(:team))
  end
  let!(:repository) { create(:repository, namespace: public_namespace) }
  let!(:tag1)       { create(:tag, name: "tag1", repository: repository) }
  let!(:tag2)       { create(:tag, name: "tag2", repository: repository) }

  before do
    @header = build_token_header(token)
  end

  context "POST /api/v1/vulnerabilities" do
    it "forces the re-schedule for all tags" do
      Tag.update_all(scanned: Tag.statuses[:scan_done])
      post "/api/v1/vulnerabilities", params: nil, headers: @header
      expect(response).to have_http_status(:accepted)

      expect(Tag.any? { |t| t.scanned != Tag.statuses[:scan_none] }).to be_falsey
    end
  end

  context "POST /api/v1/vulnerabilities/:id" do
    it "forces the re-schedule for a single tag" do
      Tag.update_all(scanned: Tag.statuses[:scan_done])
      post "/api/v1/vulnerabilities/#{tag1.id}", params: nil, headers: @header
      expect(response).to have_http_status(:accepted)

      t = Tag.find_by(name: tag1.name)
      expect(t.scanned).to eq(Tag.statuses[:scan_none])
      t = Tag.find_by(name: tag2.name)
      expect(t.scanned).to eq(Tag.statuses[:scan_done])
    end
  end
end
