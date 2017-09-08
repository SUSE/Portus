# TODO: do not require all
require "active_support/all"

require "net/http"

require_relative "api/base"
require_relative "api/application_token"
require_relative "api/user"

module Portusctl
  module API
    class Client
      API_VERSION = "v1".freeze

      RESOURCES = {
        "users"              => ["user", "u"],
        "application_tokens" => ["application_token", "at"]
      }.freeze

      def initialize
        @username = ENV["PORTUSCTL_API_USER"]
        @secret   = ENV["PORTUSCTL_API_SECRET"]
        @server   = ENV["PORTUSCTL_API_SERVER"]
      end

      def get(resource, id = nil)
        call_api(:get, 200, resource, id)
      end

      def create(resource, id, args = [])
        call_api(:create, 201, resource, id, args)
      end

      def update(resource, id, args = [])
        call_api(:update, 200, resource, id, args)
      end

      def delete(resource, id)
        call_api(:delete, 204, resource, id)
      end

      def self.normalize_resource(resource)
        if ::Portusctl::API::Client::RESOURCES.include? resource
          resource
        else
          found = nil

          ::Portusctl::API::Client::RESOURCES.each do |k, v|
            if v.include? resource
              found = k
              break
            end
          end

          found
        end
      end

      def self.print_resources
        ::Portusctl::API::Client::RESOURCES.each do |k, v|
          puts "  - #{k} (aka: #{v.join(", ")})"
        end
      end

      protected

      def call_api(cmd, code, resource, id, args = [])
        handler, err = fetch(cmd, resource, id, args)
        return err unless err.blank?

        req, uri = request(guess_method(cmd), handler.resource, handler.tail)
        if cmd == :create || cmd == :update
          # Fix arguments.
          msg = handler.send("#{cmd}_arguments!".to_sym)
          return msg unless msg.blank?

          # Add request body
          req["Content-Type"] = "application/json"
          req.body = handler.body
        end
        resp = perform_request(req, uri)

        if resp.code.to_i == code
          handler.send("on_#{cmd}_ok".to_sym, resp)
        else
          handler.send("on_#{cmd}_fail".to_sym, resp)
        end
      end

      def guess_method(cmd)
        case cmd
        when :create
          "post"
        when :update
          "put"
        else
          cmd.to_s
        end
      end

      def request(method, resource, tail)
        uri = URI.join(@server, "/api/#{API_VERSION}/#{resource}#{tail}")
        req = Net::HTTP.const_get(method.capitalize).new(uri)
        req["PORTUS-AUTH"] = "#{@username}:#{@secret}"
        [req, uri]
      end

      def perform_request(request, uri)
        options = { use_ssl: uri.scheme == "https", open_timeout: 2 }

        Net::HTTP.start(uri.hostname, uri.port, options) do |http|
          http.request(request)
        end
      end

      def fetch(method, resource, id, args)
        return [nil, "Not all env. variables have been set"] unless @username && @secret && @server

        nresource = ::Portusctl::API::Client.normalize_resource(resource)
        return [nil, "Unknown resource '#{resource}'"] unless nresource

        klass = nresource.camelize.singularize
        k = "::Portusctl::API::#{klass}".constantize.new(method, nresource, id, args)
        err = k.validate!
        [k, err]
      end
    end
  end
end
