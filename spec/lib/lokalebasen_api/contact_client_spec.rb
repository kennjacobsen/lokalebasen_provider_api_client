require 'spec_helper'

module LokalebasenApi
  describe ContactClient do

    let(:agent) { double("Agent") }
    let(:contact_params) { { :external_key => "ext_key" } }
    let(:mapped_contact) { double("MappedContact") }

    before :each do
      Resource::Root.stub_chain(:new, :get)
      Mapper::Contact.stub_chain(:new, :mapify).and_return(mapped_contact)
    end

    it "returns all contacts as maps" do
      contact_resources = 2.times.map { double("ContactResource") }
      Resource::Contact.stub_chain(:new, :all).and_return(contact_resources)
      mapped_contacts = 2.times.map { mapped_contact }
      ContactClient.new(agent).contacts.should == mapped_contacts
    end

    it "returns a mapped contact resource by external key" do
      Resource::Contact.stub_chain(:new, :find_by_external_key)
      ContactClient.new(agent).find_contact_by_external_key("ext_key").
        should == mapped_contact
    end

    it "creates a contact" do
      contact_resource = double("ContactResource")
      Resource::Contact.stub(:new).and_return(contact_resource)
      contact_resource.should_receive(:create).with(contact_params)
      ContactClient.new(agent).create_contact(contact_params)
    end

    it "returns a mapped contact of the respone from contact create" do
      Resource::Contact.stub_chain(:new, :create)
      ContactClient.new(agent).create_contact("ext_key").should == mapped_contact
    end

    it "updates a contact" do
      input_resource = double("Resource")
      contact_resource = double("ContactResource")
      Resource::Contact.stub(:new).and_return(contact_resource)
      contact_resource.should_receive(:update_by_resource).with(input_resource, contact_params)
      ContactClient.new(agent).update_contact_by_resource(input_resource, contact_params)
    end

    it "returns a mapped contact of the respone from contact update" do
      input_resource = double("Resource")
      params = { :contact => contact_params }
      Resource::Contact.stub_chain(:new, :update_by_resource)
      ContactClient.new(agent).update_contact_by_resource(input_resource, params).
        should == mapped_contact
    end
  end
end
