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

end
