require 'spec_helper'

module LokalebasenApi
  describe ContactClient do

    let(:agent) { double("Agent") }

    before :each do
      Resource::Root.stub_chain(:new, :get)
    end

    it "returns all contacts as maps" do
      mapped_contact = double("MappedContact")
      Mapper::Contact.stub_chain(:new, :mapify).and_return(mapped_contact)
      contact_resources = 2.times.map { double("ContactResource") }
      Resource::Contact.stub_chain(:new, :all).and_return(contact_resources)
      mapped_contacts = 2.times.map { mapped_contact }
      ContactClient.new(agent).contacts.should == mapped_contacts
    end

    it "returns a mapped contact resource by external key" do
      Resource::Contact.stub_chain(:new, :find_by_external_key)
      mapped_contact = double("MappedContact")
      Mapper::Contact.stub_chain(:new, :mapify).and_return(mapped_contact)
      ContactClient.new(agent).find_contact_by_external_key("ext_key").
        should == mapped_contact
    end

    it "creates a contact" do
      contact_resource = double("ContactResource")
      Resource::Contact.stub(:new).and_return(contact_resource)
      contact_params = { :external_key => "ext_key" }
      contact_resource.should_receive(:create).with(contact_params)
      Mapper::Contact.stub_chain(:new, :mapify)
      ContactClient.new(agent).create_contact(contact_params)
    end

    it "returns a mapped contact of the respone from contact create" do
      Resource::Contact.stub_chain(:new, :create)
      mapped_contact = double("MappedContact")
      Mapper::Contact.stub_chain(:new, :mapify).and_return(mapped_contact)
      ContactClient.new(agent).create_contact("ext_key").should == mapped_contact
    end
  end
end
