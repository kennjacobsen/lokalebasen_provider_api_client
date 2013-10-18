require 'spec_helper'

describe LokalebasenApi::Resource::Contact do
  let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:agent) { agent_mock(faraday_stubs) }
  let(:root_resource) { LokalebasenApi::Resource::Root.new(agent).get }
  let(:contact_resource) {
    LokalebasenApi::Resource::Contact.new(root_resource)
  }

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
end
