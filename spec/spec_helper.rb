require 'lokalebasen_api'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.include SawyerStubs
  config.include ProviderApiFixtures
  config.include FixtureHelpers
end

