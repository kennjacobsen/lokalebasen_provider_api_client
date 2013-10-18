require 'spec_helper'

describe LokalebasenApi::Mapper::Location do
  def resource(name, attributes)
    double(name, :to_hash => attributes)
  end

  it "mapifies a simple resource without photos or floor plans correctly" do
    location_resource = resource("Location", { :ext_key => "location_key" })
    expected_value = {
      :ext_key => "location_key",
      :resource => location_resource
    }
    LokalebasenApi::Mapper::Location.new(location_resource).
      mapify.should == expected_value
  end

  it "mapifies a resource with photos correctly" do
    photo_resource = resource("Photo", :ext_key => "photo_key")
    location_resource = resource("Location", { :ext_key => "location_key",
                                               :photos => [photo_resource] })
    expected_value = {
      :ext_key => "location_key",
      :resource => location_resource,
      :photos => [photo_resource.to_hash]
    }
    LokalebasenApi::Mapper::Location.new(location_resource).
      mapify.should == expected_value
  end

  it "mapifies a resource with floor plans correctly" do
    floor_plan_resource = resource("FloorPlan", { :ext_key => "floor_plan_key" })
    location_resource = resource("Location", { :ext_key => "location_key",
                                               :floor_plans => [floor_plan_resource]})
    expected_value = {
      :ext_key => "location_key",
      :resource => location_resource,
      :floor_plans => [floor_plan_resource.to_hash]
    }
    LokalebasenApi::Mapper::Location.new(location_resource).
      mapify.should == expected_value

  end
end
