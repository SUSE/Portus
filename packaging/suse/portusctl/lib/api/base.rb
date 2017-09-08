require "json"

module Portusctl
  module API
    class Base
      attr_reader :resource

      def initialize(method, resource, id, args)
        @method   = method
        @resource = resource
        @id       = id
        @args     = args
      end

      def validate!
        true
      end

      def tail
        @id.nil? ? "" : "/#{@id}"
      end

      def body
      end

      def create_arguments!
        apply_arguments!(create_parameters.dup)
      end

      def update_arguments!
        apply_arguments!(update_parameters.dup)
      end

      def on_get_ok(resp)
        json = JSON.parse(resp.body)
        JSON.pretty_generate(json)
      end

      def on_get_fail(resp)
        ["Could not get '#{real_resource}' resource:"] +
          handle_error(resp)
      end

      def on_create_ok(_resp)
        ["Resource '#{real_resource}' created."]
      end

      def on_create_fail(resp)
        ["Could not create '#{real_resource}' resource:"] +
          handle_error(resp)
      end

      def on_update_ok(_resp)
        ["Resource '#{real_resource}' updated."]
      end

      def on_update_fail(resp)
        ["Could not update '#{real_resource}' resource:"] +
          handle_error(resp)
      end

      def on_delete_ok(_resp)
        ["Resource '#{real_resource}' deleted."]
      end

      def on_delete_fail(resp)
        ["Could not remove '#{real_resource}'."] +
          handle_error(resp)
      end

      protected

      def apply_arguments!(params)
        final = {}

        @args.each do |arg|
          lval, rval = arg.split("=")

          if !params.first.include?(lval) && !params.last.include?(lval)
            warn "Ignoring unknown field '#{lval}'..."
            next
          end

          final[lval] = rval
          params.each { |p| p.delete(lval) }
        end

        str = []
        params.first.each { |p| str << "You need to set the '#{p}' field." }
        return str unless str.empty?

        @args = final.dup
        str
      end

      def create_parameters
        {}
      end

      def update_parameters
        {}
      end

      def real_resource
        @resource
      end

      def handle_error(resp)
        res  = []
        data = JSON.parse(resp.body)

        # Detailed errors with fields.
        if data["errors"]
          data["errors"].each do |k, v|
            res << "  - #{k}:"
            v.each { |l| res << "    - #{l.capitalize}." }
          end
        end

        # Simple errors
        res << "#{data["error"]}." if data["error"]
        res
      end
    end
  end
end
