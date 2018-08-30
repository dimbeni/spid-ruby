# frozen_string_literal: true

module Spid
  class Rack
    class Slo # :nodoc:
      attr_reader :app

      def initialize(app)
        @app = app
      end

      def call(env)
        @slo = SloEnv.new(env)

        return @slo.response if @slo.valid_request?

        app.call(env)
      end

      class SloEnv # :nodoc:
        attr_reader :env
        attr_reader :request

        def initialize(env)
          @env = env
          @request = ::Rack::Request.new(env)
        end

        def session
          request.session["spid"]
        end

        def clear_session
          request.session["spid"] = {}
        end

        def response
          clear_session if valid_response?
          [
            302,
            { "Location" => relay_state },
            []
          ]
        end

        def relay_state
          if !request.params["RelayState"].nil? &&
             request.params["RelayState"] != ""
            request.params["RelayState"]
          else
            Spid.configuration.default_relay_state_path
          end
        end

        def valid_get?
          request.get? &&
            Spid.configuration.slo_binding == Spid::BINDINGS_HTTP_REDIRECT
        end

        def valid_post?
          request.post? &&
            Spid.configuration.slo_binding == Spid::BINDINGS_HTTP_POST
        end

        def valid_http_verb?
          valid_post? || valid_get?
        end

        def valid_path?
          request.path == Spid.configuration.slo_path
        end

        def valid_response?
          slo_response.valid?
        end

        def valid_request?
          valid_path? && valid_http_verb?
        end

        def saml_response
          request.params["SAMLResponse"]
        end

        def slo_response
          @slo_response ||= ::Spid::Slo::Response.new(
            body: saml_response,
            session_index: session["session_index"],
            request_uuid: session["slo_request_uuid"]
          )
        end
      end
    end
  end
end
