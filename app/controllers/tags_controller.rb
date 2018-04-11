# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    authorize @tag

    @names = Tag.where(digest: @tag.digest).sort.map(&:name)
    vulns = @tag.fetch_vulnerabilities
    @vulnerabilities = vulns ? vulns.group_by(&:scanner) : nil
  end
end
