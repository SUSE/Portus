# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  namespace_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  marked       :boolean          default(FALSE)
#  description  :text(65535)
#
# Indexes
#
#  index_repositories_on_name_and_namespace_id  (name,namespace_id) UNIQUE
#  index_repositories_on_namespace_id           (namespace_id)
#

require "rails_helper"

RSpec.describe RepositoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/repositories").to route_to("repositories#index")
    end

    it "routes to #show" do
      expect(get: "/repositories/1").to route_to("repositories#show", id: "1")
    end

    it "routes to #toggle_star" do
      expect(post: "/repositories/1/toggle_star")
        .to route_to("repositories#toggle_star", id: "1")
    end
  end
end
