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

  it "finds a location by the external key" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    external_key_params = { :external_key => "location_ext_key" }
    resource = location_resource.find_by_external_key("location_ext_key")
    resource.to_hash.should include(external_key_params)
    resource.should be_an_instance_of(Sawyer::Resource)
  end

  it "fails with NotFoundException if the no location is found with the given external key" do
    external_key_params = { :external_key => "location_ext_key" }
    expect {
      location_resource.find_by_external_key("wrong_ext_key")
    }.to raise_error(LokalebasenApi::NotFoundException)
  end
end
