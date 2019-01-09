# frozen_string_literal: true

module Portus
  module Background
    # GarbageCollector cleans up the registry from old tags. The behavior of
    # this task depends on the `delete.garbage_collector` configuration option.
    class GarbageCollector
      def initialize
        @tags = nil
      end

      def sleep_value
        60
      end

      def work?
        return false unless enabled?

        @tags = tags_to_be_collected
        @tags.any?
      end

      def enabled?
        APP_CONFIG.enabled?("delete.garbage_collector")
      end

      def disable?
        false
      end

      def execute!
        @tags ||= tags_to_be_collected
        service = ::Tags::DestroyService.new(User.find_by(username: "portus"))

        @tags.each do |tag|
          next if service.execute(tag)

          Rails.logger.tagged(:garbage_collector) { Rails.logger.warn(service.error.to_s) }
        end
      end

      def to_s
        "Garbage collector"
      end

      protected

      def tags_to_be_collected
        tags = Tag.where(marked: false).where("updated_at < ?", older_than)
        return tags if APP_CONFIG["delete"]["garbage_collector"]["tag"].blank?

        not_match_tags = tags.reject { |t| t.name.match(tag_regexp) }
        not_match_image = not_match_tags.map(&:image_id)

        tags.select { |t| t.name.match(tag_regexp) && !not_match_image.include?(t.image_id) }
      end

      def older_than
        APP_CONFIG["delete"]["garbage_collector"]["older_than"].to_i.days.ago
      end

      def tag_regexp
        Regexp.new(APP_CONFIG["delete"]["garbage_collector"]["tag"])
      end
    end
  end
end
