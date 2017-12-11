# frozen_string_literal: true

# == Schema Information
#
# Table name: namespaces
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer
#  registry_id :integer          not null
#  global      :boolean          default(FALSE)
#  description :text(65535)
#  visibility  :integer
#
# Indexes
#
#  index_namespaces_on_name_and_registry_id  (name,registry_id) UNIQUE
#  index_namespaces_on_registry_id           (registry_id)
#  index_namespaces_on_team_id               (team_id)
#

require "rails_helper"

RSpec.describe NamespacesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/namespaces").to route_to("namespaces#index")
    end

    it "routes to #show" do
      expect(get: "/namespaces/1").to route_to("namespaces#show", id: "1")
    end
  end
end
