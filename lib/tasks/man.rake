# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  require "man_pages"

  namespace :portus do
    desc "Build man pages"
    task generate_man_pages: :environment do
      ManPages.new.generate!
    end
  end
end
