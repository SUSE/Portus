# frozen_string_literal: true

require "portus/ldap/authenticatable"
Warden::Strategies.add(:ldap_authenticatable, ::Portus::LDAP::Authenticatable)
