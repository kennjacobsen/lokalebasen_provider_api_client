shared_examples "an asset" do |resource_name, asset_data_key|
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:location_resource) {
    LokalebasenApi::Resource::Location.new(root_resource).
      find_by_external_key("location_ext_key")
  }
  let(:asset_url) { "http://host.com/path/to/asset.png" }
  let(:asset_external_key) { "#{resource_name}_external_key1" }

  before :each do
    stub_get(faraday_stubs, "/api/provider", 200, root_fixture)
    stub_get(faraday_stubs, "/api/provider/locations", 200, location_list_fixture)
  end

  it "performs the correct requests on creation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/#{resource_name}", 202, asset_job_fixture)
    asset_url = "http://host.com/path/to/asset.png"
    asset_resource.public_send(:create, asset_url, asset_external_key)
    faraday_stubs.verify_stubbed_calls
  end

  it "posts with the correct parameters" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    params = {
      asset_data_key => {
        :external_key => asset_external_key,
        :url => asset_url,
        :position => 1
      }
    }
    location_resource.rels[resource_name].
      should_receive(:post).
      with(params).
      and_return(double.as_null_object)
    asset_resource.public_send(:create, asset_url, asset_external_key, 1)
  end

  it "returns a sawyer resource on creation" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_post(faraday_stubs, "/api/provider/locations/123/#{resource_name}", 202, asset_job_fixture)
    asset = asset_resource.public_send(:create, asset_url, asset_external_key)
    asset.should be_an_instance_of(Sawyer::Resource)
    asset.to_hash.should include fixture_to_response(asset_job_fixture)
  end

  it "performs the correct requests on deletion" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_delete(faraday_stubs, "/api/provider/#{resource_name}/1", 200, location_fixture)
    asset_resource.public_send(:delete, "#{resource_name}_external_key1")
    faraday_stubs.verify_stubbed_calls
  end

  it "returns the response code 200 on deletion" do
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
    stub_delete(faraday_stubs, "/api/provider/#{resource_name}/1", 200, location_fixture)
    asset_resource.public_send(:delete, "#{resource_name}_external_key1").should == 200
  end
end
