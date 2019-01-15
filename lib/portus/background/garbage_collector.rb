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
        return if Tag.all.count <= APP_CONFIG["delete"]["garbage_collector"]["keep_latest"].to_i

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
        tags = Tag.where(marked: false)
                  .where("updated_at < ? AND (pulled_at < ? OR pulled_at IS NULL)",
                         older_than,
                         older_than)
        return tags if APP_CONFIG["delete"]["garbage_collector"]["tag"].blank?

        rx = tag_regexp
        tags.select { |t| t.name.match(rx) }
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
