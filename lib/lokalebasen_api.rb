require "lokalebasen_api/version"
require "lokalebasen_api/client"

module LokalebasenApi
  def self.client(credentials, service_url)
    Client.new(credentials, false, service_url)
  end
end
