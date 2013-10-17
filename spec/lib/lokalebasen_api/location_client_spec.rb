require 'spec_helper'

describe LokalebasenApi::LocationClient do
  let(:agent) { double("Agent") }

  before :each do
    LokalebasenApi::Resource::Root.stub_chain(:new, :get)
  end

  it "returns all location resources as map" do
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    location_resources = 2.times.map { double("LocationResource") }
    LokalebasenApi::Resource::Location.stub_chain(:new, :all).and_return(location_resources)
    mapped_locations = 2.times.map { mapped_location }
    LokalebasenApi::LocationClient.new(agent).locations.should == mapped_locations
  end

  it "returns a mapped resource by external key" do
    LokalebasenApi::Resource::Location.stub_chain(:new, :find_by_external_key)
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    LokalebasenApi::LocationClient.new(agent).
      location("ext_key").should == mapped_location
  end

  it "returns a mapped result of the location creation" do
    LokalebasenApi::Resource::Location.stub_chain(:new, :create)
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    location_params = { :location => { :external_key => "external_key "}}
    LokalebasenApi::LocationClient.new(agent).
      create_location(location_params).should == mapped_location
  end

  it "returns a mapped result of the updated location" do
    LokalebasenApi::Resource::Location.stub_chain(:new, :update)
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    location_params = { "location" => { "external_key" => "external_key "}}
    LokalebasenApi::LocationClient.new(agent).
      update_location(location_params).should == mapped_location
  end

  it "returns a mapped result of the deactivated location" do
    LokalebasenApi::Resource::Location.stub_chain(:new, :deactivate)
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    LokalebasenApi::LocationClient.new(agent).
      deactivate("external_key").should == mapped_location
  end

  it "returns a mapped result of the activated location" do
    LokalebasenApi::Resource::Location.stub_chain(:new, :activate)
    mapped_location = double("MappedLocation")
    LokalebasenApi::Mapper::Location.stub_chain(:new, :mapify).and_return(mapped_location)
    LokalebasenApi::LocationClient.new(agent).
      activate("external_key").should == mapped_location
  end

  shared_examples "an asset client" do |asset_type|
    let(:asset_ext_key) { "asset_ext_key" }
    let(:location_ext_key) { "location_ext_key" }
    let(:asset_url) { "http://myhost.com/image/123" }
    let(:location_client) {
      LokalebasenApi::LocationClient.new(agent)
    }
    let(:location) { double("Location") }
    let!(:asset_resource) { asset_resource_class.new(location) }

    before :each do
      asset_resource_class.stub(:new).and_return(asset_resource)
    end

    it "creates an #{asset_type}" do
      LokalebasenApi::Resource::Location.stub_chain(:new, :find_by_external_key)
      LokalebasenApi::Mapper::Job.stub_chain(:new, :mapify)
      asset_resource.should_receive(:create).with(asset_url, asset_ext_key)
      location_client.public_send(
        "create_#{asset_type}",
        asset_url,
        asset_ext_key,
        location_ext_key
      )
    end

    it "returns a mapped job when creating a #{asset_type}" do
      LokalebasenApi::Resource::Location.stub_chain(:new, :find_by_external_key)
      mapped_job = double("MappedJob")
      LokalebasenApi::Mapper::Job.stub_chain(:new, :mapify).and_return(mapped_job)
      asset_resource.stub(:create)
      location_client.public_send(
        "create_#{asset_type}",
        asset_url,
        asset_ext_key,
        location_ext_key
      ).should == mapped_job
    end

    it "deletes an #{asset_type}" do
      LokalebasenApi::Resource::Location.stub_chain(:new, :find_by_external_key)
      LokalebasenApi::Mapper::Job.stub_chain(:new, :mapify)
      asset_resource.should_receive(:delete).with(asset_ext_key)
      location_client.public_send(
        "delete_#{asset_type}",
        asset_ext_key,
        location_ext_key
      )
    end
  end

  describe "photos" do
    it_behaves_like "an asset client", :photo do
      let(:asset_resource_class) { LokalebasenApi::Resource::Photo }
    end
  end
end
