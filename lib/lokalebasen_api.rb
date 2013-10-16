require "lokalebasen_api/version"
require "lokalebasen_api/client"
require "lokalebasen_api/response_checker"
require "lokalebasen_api/resource/root"

module LokalebasenApi
  def self.client(credentials, service_url)
    Client.new(credentials, service_url)
  end
end
