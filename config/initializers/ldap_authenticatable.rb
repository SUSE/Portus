# frozen_string_literal: true

require "portus/ldap"
Warden::Strategies.add(:ldap_authenticatable, Portus::LDAP)
