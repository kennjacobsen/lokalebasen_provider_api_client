require 'spec_helper'

describe LokalebasenApi::Resource::Contact do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:contact_resource) {
    LokalebasenApi::Resource::Contact.new(root_resource)
  }
  let(:contact_params) { { :external_key => "contact_ext_key1" } }

  before :each do
    stub_get(faraday_stubs, "/api/provider", 200, root_fixture)
    stub_get(faraday_stubs, "/api/provider/contacts", 200, contact_list_fixture)
  end

  it "returns all contacts" do
    external_key_values = [
      { :external_key => "contact_ext_key1" },
      { :external_key => "contact_ext_key2"}
    ]
    contact_resource.all.each_with_index do |contact, index|
      contact.should be_an_instance_of(Sawyer::Resource)
      contact.to_hash.should include(external_key_values[index])
    end
  end

  it "finds a contact by the external key" do
    stub_get(faraday_stubs, "/api/provider/contacts/123", 200, contact_fixture)
    resource = contact_resource.find_by_external_key("contact_ext_key1")
    resource.to_hash.should include(contact_params)
    resource.should be_an_instance_of(Sawyer::Resource)
  end

  it "performs the correct requests on creation" do
    stub_post(faraday_stubs, "/api/provider/contacts", 201, contact_fixture)
    contact_resource.create(contact_params)
    faraday_stubs.verify_stubbed_calls
  end

  it "returns a resource with location params on creation" do
    stub_post(faraday_stubs, "/api/provider/contacts", 201, contact_fixture)
    contact = contact_resource.create(contact_params)
    contact.to_hash.should include(contact_params)
    contact.should be_an_instance_of(Sawyer::Resource)
  end
end
