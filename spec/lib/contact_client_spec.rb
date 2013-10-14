require 'spec_helper'

module LokalebasenApi
  describe ContactClient do

    let(:external_key) { "external_key" }
    let(:contact){ Map.new({ name: "TEST", external_key: external_key }) }
    let(:contacts) { [contact] }
    let(:contact_rel) { double(contacts: contacts) }
    let(:contacts_rel) { double(get: double(data: contact_rel)) }

    # Root url
    let(:root_rels) { { contacts: contacts_rel } }
    let(:root_resource) { double(rels: root_rels)}
    let(:root) { double(status: 200, data: root_resource) }
    let(:agent) { double(start: root) }

    let(:service_url) { "http://staging.lokalebasen.dk/api/provider/root.json" }
    let(:api_key) { "1c335bc7cb911bcec80f05968c6e4f70522c5ecb" }
    let(:client) { LokalebasenApi.client({:api_key => api_key}, service_url) }

    it "returns all contacts" do
      contact_client = ContactClient.new(agent)
      contact_client.contacts.should == [ contact.merge({resource: contact}) ]
    end

  end
end
