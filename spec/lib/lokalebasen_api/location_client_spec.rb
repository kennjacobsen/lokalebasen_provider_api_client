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
end
