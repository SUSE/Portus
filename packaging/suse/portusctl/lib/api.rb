require "json"

# TODO: it should be more OO, as in, each resource is a class subclassing a base
# class. The base class does the usual stuff, while each subclass will overwrite
# some behavior

module Portusctl
  module API
    class Client
      API_VERSION = "v1".freeze

      # TODO: allow singular (e.g. delete user 3)
      RESOURCES = ["users", "application_tokens"].freeze

      # TODO: can this be taken from grape ?
      PARAMETERS = {
        "users"              => [["username", "email", "password"], ["display_name"]],
        "application_tokens" => [["application", "id"], []]
      }.freeze

      def initialize
        @username = ENV["PORTUSCTL_API_USER"]
        @secret   = ENV["PORTUSCTL_API_SECRET"]
        @server   = ENV["PORTUSCTL_API_SERVER"]
      end

      def get(resource, args = [])
        test!

        if resource == "application_tokens"
          raise "We need the ID of the user!" if args.empty?
          resource = "users"
          tail = "/#{args.first}/application_tokens"
        else
          tail = args.empty? ? "" : "/#{args.join("/")}"
        end

        resp = request("get", resource, tail)
        if resp.code.to_i == 200
          json = JSON.parse(resp.body)
          puts JSON.pretty_generate(json)
        end
      end

      def create(resource, args = [])
        test!

        params = check_arguments(resource, args)
        original = resource

        # TODO: yikes ... ugly...
        if resource == "application_tokens"
          raise "We need the ID of the user!" if args.empty?
          resource = "users"
          tail = "/#{params["id"]}/application_tokens"
          params.delete("id")
          body = params
        else
          body = { "user" => params }
          tail = ""
        end

        req, uri = bare_request("post", resource, tail)
        req["Content-Type"] = "application/json"
        req.body = body.to_json
        resp = do_request(req, uri)

        if resp.code.to_i == 201
          puts "Resource '#{original}' created"
          # TODO: improve
          puts resp.body if resp.body
        else
          puts "Could not create '#{original}' resource:"
          handle_error(resp)
        end
      end

      def delete(resource, id)
        test!

        resource = "users/application_tokens" if resource == "application_tokens"
        tail     = "/#{id}"
        resp     = request("delete", resource, tail)

        # TODO
        if resp.code.to_i == 204
          puts "Resource '#{resource}' deleted"
        else
          puts "Could not remove resource"
        end
      end

      protected

      def request(method, resource, tail)
        req, uri = bare_request(method, resource, tail)
        do_request(req, uri)
      end

      def bare_request(method, resource, tail)
        uri = URI.join(@server, "/api/#{API_VERSION}/#{resource}#{tail}")
        req = Net::HTTP.const_get(method.capitalize).new(uri)
        req["PORTUS-AUTH"] = "#{@username}:#{@secret}"
        [req, uri]
      end

      def do_request(request, uri)
        options = { use_ssl: uri.scheme == "https", open_timeout: 2 }

        Net::HTTP.start(uri.hostname, uri.port, options) do |http|
          http.request(request)
        end
      end

      def check_arguments(resource, args)
        params = PARAMETERS[resource].dup
        final = {}

        args.each do |arg|
          lval, rval = arg.split("=")

          if !params.first.include?(lval) && !params.last.include?(lval)
            warn "Ignoring unknown field '#{lval}'..."
            next
          end

          final[lval] = rval
          params.each { |p| p.delete(lval) }
        end

        params.first.each { |p| warn "You need to set the '#{p}' field." }
        exit 1 unless params.first.empty?

        final
      end

      # TODO: check that resource exists
      def test!
        unless @username && @secret && @server
          raise StandardError, "Not all env. variables have been set"
        end
      end

      def handle_error(resp)
        data = JSON.parse(resp.body)
        puts data.inspect
        data["errors"].each do |k, v|
          puts "  - #{k}:"
          v.each { |l| puts "    - #{l.capitalize}." }
        end
      end
    end
  end
end
