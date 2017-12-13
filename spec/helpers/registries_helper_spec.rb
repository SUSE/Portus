# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistriesHelper, type: :helper do
  let!(:registry) { create(:registry) }

  describe "#registry_status_icon" do
    it "renders with chain icon if reachable" do
      allow(registry).to receive(:reachable?).and_return("")

      html = helper.registry_status_icon(registry)
      expect(html).to include('<i class="fa fa-lg fa-chain" title="Reachable')
    end

    it "renders with chain-broken icon if unreachable" do
      allow(registry).to receive(:reachable?).and_return("Something")

      html = helper.registry_status_icon(registry)
      expect(html).to include('<i class="fa fa-lg fa-chain-broken" title="Something')
    end
  end
end
