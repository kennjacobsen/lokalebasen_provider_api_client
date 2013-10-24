require 'spec_helper'

describe LokalebasenApi::Resource::Location do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:location_resource) {
    LokalebasenApi::Resource::Location.new(root_resource).
      find_by_external_key("location_ext_key")
  }
  let(:subscription_resource) {
    LokalebasenApi::Resource::Subscription.new(location_resource)
  }

  before :each do
    stub_get(faraday_stubs, "/api/provider", 200, root_fixture)
    stub_get(faraday_stubs, "/api/provider/locations", 200, location_list_fixture)
    stub_get(faraday_stubs, "/api/provider/locations/123", 200, location_fixture)
  end

  it "returns all subscriptions" do
    stub_get(faraday_stubs, "/api/provider/locations/123/subscriptions", 200, subscription_list_fixture)
    subscription_values = [
      { :contact => "http://www.lokalebasen.dk/api/provider/contacts/123" },
      { :contact => "http://www.lokalebasen.dk/api/provider/contacts/456" },
    ]
    subscription_resource.all.each_with_index do |location, index|
      location.should be_an_instance_of(Sawyer::Resource)
      location.to_hash.should include(subscription_values[index])
    end
  end

  it "performs the correct requests when creating a subscription" do
    stub_post(faraday_stubs, "/api/provider/locations/123/subscriptions", 200, subscription_fixture)
    params = { :contact => "/api/provider/contacts/123" }
    subscription_resource.create(params)
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a sawyer resource on creation" do
    stub_post(faraday_stubs, "/api/provider/locations/123/subscriptions", 200, subscription_fixture)
    params = { :contact => "/api/provider/contacts/123" }
    subscription = subscription_resource.create(params)
    subscription.should be_an_instance_of(Sawyer::Resource)
    subscription.to_hash.should include params
  end
end
