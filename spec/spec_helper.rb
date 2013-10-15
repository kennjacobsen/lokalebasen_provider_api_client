require 'lokalebasen_api'
require 'vcr'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.include SawyerStubs
  config.include ProviderApiFixtures
  config.include FixtureHelpers
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

