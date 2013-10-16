require 'spec_helper'

describe LokalebasenApi::Resource::Location do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:location_resource) {
    LokalebasenApi::Resource::Location.new(root_resource)
  }

  before :each do
    stub_get(faraday_stubs, "/api/provider", 200, root_fixture)
    stub_get(faraday_stubs, "/api/provider/locations", 200, location_list_fixture)
  end

  it "returns all locations" do
    external_key_values = [
      { :external_key => "location_ext_key" },
      { :external_key => "location_ext_key2"}
    ]
    location_resource.all.each_with_index do |location, index|
      location.should be_an_instance_of(Sawyer::Resource)
      location.to_hash.should include(external_key_values[index])
    end
  end
end
