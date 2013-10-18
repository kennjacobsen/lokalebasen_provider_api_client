require 'spec_helper'

describe LokalebasenApi::Resource::Location do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:location_resource) {
    LokalebasenApi::Resource::Location.new(root_resource)
  }
  let(:location_params) { { :external_key => "location_ext_key" }}
  let(:params) { { :location => location_params }}

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
    resource = location_resource.find_by_external_key("location_ext_key")
    resource.to_hash.should include(location_params)
    resource.should be_an_instance_of(Sawyer::Resource)
  end

  it "fails with NotFoundException if the no location is found with the given external key" do
    expect {
      location_resource.find_by_external_key("wrong_ext_key")
    }.to raise_error(LokalebasenApi::NotFoundException)
  end

  it "returns true if a location with given external key exists" do
    location_resource.exists?("location_ext_key").should be_true
  end

  it "returns false if a location with given external key exists" do
    location_resource.exists?("fake_external_key").should be_false
  end

  it "performs the correct requests on creation" do
    stub_post(faraday_stubs, "/api/provider/locations", 201, location_fixture)
    location_resource.create(params)
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a resource with location params on creation" do
    stub_post(faraday_stubs, "/api/provider/locations", 201, location_fixture)
    location = location_resource.create(params)
    location.to_hash.should include(location_params)
    location.should be_an_instance_of(Sawyer::Resource)
  end

  it "performs the correct requests on update" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_put(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    location_resource.update("location_ext_key", params)
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a resource with location params on update" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_put(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    location = location_resource.update("location_ext_key", params)
    location.to_hash.should include(location_params)
    location.should be_an_instance_of(Sawyer::Resource)
  end

  it "performs the correct requests on deactivation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/deactivations", 200, location_fixture)
    location_resource.deactivate("location_ext_key")
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a resource with location params on deactivation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/deactivations", 200, location_fixture)
    return_value = location_resource.deactivate("location_ext_key")
    return_value.to_hash.should include(location_params)
    return_value.should be_an_instance_of(Sawyer::Resource)
  end

  it "performs the correct requests on activation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/activations", 200, location_fixture)
    location_resource.activate("location_ext_key")
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a sawyer resource with correct params on activation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/activations", 200, location_fixture)
    return_value = location_resource.activate("location_ext_key")
    return_value.to_hash.should include(location_params)
    return_value.should be_an_instance_of(Sawyer::Resource)
  end
end
