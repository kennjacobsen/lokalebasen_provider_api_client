require 'spec_helper'
require 'faraday/adapter/test'

describe LokalebasenApi::Client do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:client) {
    LokalebasenApi::Client.new(
      {:api_key => "ApiKey"},
      "http://lokalebasen.dev",
      :agent => agent
    )
  }

  before :each do
    stub_get(faraday_stubs, "/api/provider", 200, root_fixture)
    stub_get(faraday_stubs, "/api/provider/locations", 200, location_list_fixture)
  end

  it "finds all locations" do
    expected_value = [
      { "external_key" => "location_ext_key" },
      { "external_key" => "location_ext_key2"}
    ]
    client.locations.each_with_index do |location, index|
      location.should include(expected_value[index])
    end
  end

  it "finds a location by the external key" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    expected_value = { "external_key" => "location_ext_key" }
    client.location("location_ext_key").should include fixture_to_response(location_fixture)
  end

  it "fails with NotFoundException if the no location is found with the given external key" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 404, error_fixture)
    expect {
      client.location("wrong-external-key")
    }.to raise_error(LokalebasenApi::NotFoundException)
  end

  it "returns true if a location with given external key exists" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    expect(client.exists?("location_ext_key")).to be true
  end

  it "returns false if a location with given external key does not exist" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    expect(client.exists?("fake_external_key")).to be false
  end

  it "creates a location" do
    stub_post(faraday_stubs, "/api/provider/locations", 201, location_fixture)
    location = { "location" => { "external_key" => "location_ext_key" } }
    client.create_location(location).should include fixture_to_response(location_fixture)
    faraday_stubs.verify_stubbed_calls
  end

  it "fails with RuntimeError if creation fails" do
    stub_post(faraday_stubs, "/api/provider/locations", 402, error_fixture)
    location = { "location" => { "external_key" => "location_ext_key" } }
    expect {
      client.create_location(location)
    }.to raise_error(RuntimeError)
  end

  it "updates a location" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_put(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    location = { "location" => { "external_key" => "location_ext_key" } }
    client.update_location(location).should include fixture_to_response(location_fixture)
    faraday_stubs.verify_stubbed_calls
  end

  it "fails with RuntimeError if location update fails" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_put(faraday_stubs, "/api/provider/locations/123", 402, error_fixture)
    location = { "location" => { "external_key" => "location_ext_key" } }
    expect {
      client.update_location(location)
    }.to raise_error(RuntimeError)
  end

  it "deactivates a location" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/deactivations", 200, location_fixture)
    expected_value = { "external_key" => "location_ext_key" }
    client.deactivate("location_ext_key").should include fixture_to_response(location_fixture)
    faraday_stubs.verify_stubbed_calls
  end

  it "fails with RuntimeError if the location to be deactivated does not exist" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/deactivations", 404, error_fixture)
    expect {
      client.deactivate("location_ext_key")
    }.to raise_error(RuntimeError)
  end

  it "activates a location" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/activations", 200, location_fixture)
    client.activate("location_ext_key").should include fixture_to_response(location_fixture)
    faraday_stubs.verify_stubbed_calls
  end

  it "fails with RuntimeError if the location to be activated does not exist" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/activations", 404, location_fixture)
    expect {
      client.activate("location_ext_key")
    }.to raise_error(RuntimeError)
  end

  shared_examples "an asset client and" do |asset_type, resource_name|
    it "creates a #{asset_type}" do
      stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
      stub_post(faraday_stubs, "/api/provider/locations/123/#{resource_name}", 202, asset_job_fixture)
      client.public_send(
        "create_#{asset_type}",
        "http://host.com/path/to/asset.png",
        "external_key",
        "location_ext_key"
      ).should include fixture_to_response(asset_job_fixture)
      faraday_stubs.verify_stubbed_calls
    end

    it "fails with RuntimeError if creation of #{asset_type} fails" do
      stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
      stub_post(faraday_stubs, "/api/provider/locations/123/#{resource_name}", 402, asset_job_fixture)
      expect {
        client.public_send(
          "create_#{asset_type}",
          "http://host.com/path/to/asset.png",
          "external_key",
          "location_ext_key"
        )
      }.to raise_error(RuntimeError)
    end

    it "deletes a #{asset_type}" do
      stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
      stub_delete(faraday_stubs, "/api/provider/#{resource_name}/1", 200, location_fixture)
      expect(
        client.public_send(
          "delete_#{asset_type}",
          "#{resource_name}_external_key1",
          "location_ext_key"
        )
      ).to be 200
      faraday_stubs.verify_stubbed_calls
    end

    it "fails with NotFoundException if trying to delete asset with wrong external key" do
      stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
      stub_delete(faraday_stubs, "/api/provider/#{resource_name}/1", 402, location_fixture)
      expect {
        client.public_send(
          "delete_#{asset_type}",
          "bad_external_key",
          "location_ext_key"
        ).to raise_error(LokalebasenApi::NotFoundException)
      }
    end
  end

  describe "photos" do
    it_behaves_like "an asset client and", "photo", "photos"
  end

  describe "prospectuses" do
    it_behaves_like "an asset client and", "prospectus", "prospectuses"
  end

  describe "floor_plans" do
    it_behaves_like "an asset client and", "floorplan", "floor_plans"
  end
end
