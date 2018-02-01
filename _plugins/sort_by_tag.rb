# frozen_string_literal: true

module Jekyll
  # SortByTag returns the given paths sorted by tag.
  module SortByTag
    def sort_by_tag(input)
      input.group_by { |_, v| v.first.last["tags"].first }
    end
  end
end

Liquid::Template.register_filter(Jekyll::SortByTag)
