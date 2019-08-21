# frozen_string_literal: true

# See: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
OmniAuth.config.allowed_request_methods = %i[post get]
