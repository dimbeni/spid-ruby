# frozen_string_literal: true

require "spid/authn_request"
require "spid/logout_request"
require "spid/sso"
require "spid/slo"
require "spid/metadata"
require "spid/version"
require "spid/identity_provider_configuration"
require "spid/service_provider_configuration"
require "spid/identity_provider_manager"
require "spid/service_provider_manager"

module Spid # :nodoc:
  class UnknownAuthnComparisonMethodError < StandardError; end
  class UnknownAuthnContextError < StandardError; end
  class UnknownDigestMethodError < StandardError; end
  class UnknownSignatureMethodError < StandardError; end

  EXACT_COMPARISON = :exact
  MININUM_COMPARISON = :minumum
  BETTER_COMPARISON = :better
  MAXIMUM_COMPARISON = :maximum

  COMPARISON_METHODS = [
    EXACT_COMPARISON,
    MININUM_COMPARISON,
    BETTER_COMPARISON,
    MAXIMUM_COMPARISON
  ].freeze

  SHA256 = XMLSecurity::Document::SHA256
  SHA384 = XMLSecurity::Document::SHA384
  SHA512 = XMLSecurity::Document::SHA512

  DIGEST_METHODS = [
    SHA256,
    SHA384,
    SHA512
  ].freeze

  RSA_SHA256 = XMLSecurity::Document::RSA_SHA256
  RSA_SHA384 = XMLSecurity::Document::RSA_SHA384
  RSA_SHA512 = XMLSecurity::Document::RSA_SHA512

  SIGNATURE_METHODS = [
    RSA_SHA256,
    RSA_SHA384,
    RSA_SHA512
  ].freeze

  L1 = "https://www.spid.gov.it/SpidL1"
  L2 = "https://www.spid.gov.it/SpidL2"
  L3 = "https://www.spid.gov.it/SpidL3"

  AUTHN_CONTEXTS = [
    L1,
    L2,
    L3
  ].freeze

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration # :nodoc:
    attr_accessor :sp_configuration_file_path
    attr_accessor :sp_certificates_dir_path
    attr_accessor :idp_metadata_dir_path

    def initialize
      @sp_certificates_dir_path = "sp_certificates"
      @sp_configuration_file_path = "service_providers.yml"
      @idp_metadata_dir_path = "idp_metadata"
    end
  end
end
