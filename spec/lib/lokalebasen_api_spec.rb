# encoding: utf-8
require 'spec_helper'
require 'securerandom'

describe LokalebasenApi do



  # let(:service_url) { "http://localhost:3000/api/provider/locations.json" }
  # let(:service_url) { "http://staging.lokalbasen.se/api/provider/locations.json" }
  let(:service_url) { "http://staging.lokalebasen.dk/api/provider/root.json" }
  # let(:service_url) { "http://localhost:3000/api/provider" }
  let(:api_key) { "356d8acb815865941b5d9515ef00a84f0c14d2b1" } # staging api_key for Kungsleden
  # let(:api_key) { "03e7ad6c157dcfd1195144623d06ad0d2498e9ec" } # localhost api_key for Jeudan

  let(:ext_key) { "TEST_KEY" }
  let(:asset_ext_key) { "ASSET_KEY" }
  let(:ok_status) {  double(status: 200) }
  let(:delete_ok) {  double(delete: ok_status) }
  let(:rest_ok) {  double(delete: ok_status, post: ok_status, put: ok_status, get: ok_status) }
  let(:location) { double(external_key: ext_key, rels: {self: double}  ) }
  let(:location_res) { double(location: location) }

  let(:error_status) {  double(status: 400, data: double(message: "SOME 400 ERROR")) }
  let(:ext_key_non_existing) { "40PQ32KUC6BSC3XR" }
  let(:prospectus_url){ "http://www.lokalebasen-uploads.dk/artikler/2013_06_10_alectia_indretning/slides.pdf" }
  let(:prospectus_ext_key){ "PROSPECTUS_EXT_KEY" }
  let(:client) { LokalebasenApi.client({:api_key => api_key}, service_url) }

  let(:location_test) {
    {"location" => {
      "title"=>"test",
      "description"=>"good",
      "street_name"=>"malmstroeget",
      "house_number"=>"20",
      "floor"=>nil,
      "side"=>nil,
      "postal_code"=>22250,
      "latitude"=>52.5,
      "longitude"=>12.2,
      "state"=>"closed",
      "kind"=>"office",
      "area_from"=>2000.0,
      "area_to"=>nil,
      "external_key"=>"39PQ32KUC6BSC3AS",
      "yearly_rent_per_m2_from"=>{"cents"=>33000, "currency"=>"DKK"},
      "photos"=>
      [{"external_key"=>"TEST_KEY", "url"=>"/uploads/0014/2921/tokay.png"},
       {"external_key"=>"TEST_KEY10", "url"=>"/uploads/0014/3021/tokay.png"}],
      "floor_plans"=>
      [{"external_key"=>"TEST_KEY", "url"=>"/uploads/0014/2922/tokay.png"}],
      "yearly_operational_cost_per_m2_from"=>{"cents"=>33000, "currency"=>"DKK"}
    }}
  }

  let(:locations) { [{external_key: "EXISTING_GUID"}] }

  describe "#create_prospectus" do
    it "returns state" do 
      VCR.use_cassette('create_prospectus') do
        resp = client.create_prospectus(prospectus_url, prospectus_ext_key, "TEST_KEY")
        resp.should == {"state"=>"enqueued", "url"=>"http://staging.lokalebasen.dk/api/provider/asset_jobs/30900"}
      end
    end

    it "url encoding" do
      
    end
  end 

  describe "#delete_prospectus" do
    it "returns nil" do 
      prospectus = double(external_key: asset_ext_key, rels: {self: delete_ok} )
      location.stub(prospectus: prospectus)
      client.stub(add_method: nil, location_res: location_res)
      delete_ok.should_receive(:delete) # The test
      client.delete_prospectus(asset_ext_key, ext_key).should be_nil
    end
  end

  it "returns true if location exist" do
    client.should_receive(:locations).and_return(locations)
    client.exists?("EXISTING_GUID").should be_true
  end

  it "returns false if location doesn't exist" do
    client.should_receive(:locations).and_return(locations)
    client.exists?("NOT_EXISTING_GUID").should be_false
  end

  # it "creates floorplan" do
  #   floorplan_url = "http://www.skyen.dk/worldpixelsPictures/BigNarrowPictures/tokay.png"
  #   floorplan_ext_key = "TEST_KEY3"
  #   # VCR.use_cassette('create_floorplan') do
  #     resp = client.create_floorplan(floorplan_url, floorplan_ext_key, ext_key)
  #     resp["external_key"] == "TEST_KEY3"
  #   # end
  # end

  it "deletes floorplan" do
    floor_plan = double(external_key: asset_ext_key, rels: {self: delete_ok} )
    location.stub(floor_plans:[floor_plan])
    client.stub(add_method: nil, location_res: location_res)
    delete_ok.should_receive(:delete) # The test
    client.delete_floorplan(asset_ext_key, ext_key).should be_nil
  end

  it "deletes photo" do
    photo_ext_key = "TEST_KEY10"
    VCR.use_cassette('delete_photo') do
      client.delete_photo(photo_ext_key, ext_key)
    end
  end

  it "fails when trying to delete photo with non_existing key" do
    photo_ext_key = "SOME_NON_EXISTING_KEY"
    VCR.use_cassette('delete_non_existing_photo') do
      expect { client.delete_photo(photo_ext_key, ext_key) }.to raise_error LokalebasenApi::NotFoundException
    end
  end

  it "creates photo" do
    photo_url = "http://www.cloud.com/narnia_map.jpg"

    photos_rel = double
    location.stub(rels: double(photos: photos_rel))
    location.stub(photos:[])
    
    job = double(to_hash: { external_key: asset_ext_key })
    job.stub(rels: { self: double(href_template: "SOME_URL") })
    post_response = double(data: double(job: job), status: 200)
    client.stub(add_method: double(post: post_response), location_res: location_res)

    photos_rel.should_receive(:post) # The test

    resp = client.create_photo(photo_url, asset_ext_key, ext_key)
    resp.external_key.should == asset_ext_key

  end

  # it "fails when trying to create photo with existing key" do
  #   VCR.use_cassette('create_photo_failure_existing_key') do
  #     photo_url = "http://www.skyen.dk/worldpixelsPictures/BigNarrowPictures/tokay.png"
  #     photo_ext_key = "TEST_KEY10"
  #     expect { client.create_photo(photo_url, photo_ext_key, ext_key) }.to raise_error LokalebasenApi::NotFoundException
  #   end
  # end

  # it "returns a list of locations" do
  #   VCR.use_cassette('locations') do
  #     locations = client.locations
  #     locations.length.should == 452
  #     locations.each { |loc|  puts loc.external_key }
  #   end
  # end

  # it "fails if specified location doesn't exist" do
  #   VCR.use_cassette('not_existing_location') do
  #     expect { client.location(ext_key_non_existing) }.to raise_error LokalebasenApi::NotFoundException
  #   end
  # end

  # it "returns a specified location" do
  #   # VCR.use_cassette('location') do
  #     location = client.location(ext_key)
  #     location_test["location"]["state"] = "active"
  #     # location.should == location_test["location"]
  #     puts location.inspect
  #     location.should_not be_nil
  #   # end
  # end

  # it "activates location" do
  #   client.stub(can_be_activated?: true)
  #   client.should_receive(:set_state).with(:activation, ext_key).and_return(nil)
  #   client.activate(ext_key)
  # end

  # it "doesn't activate location with no activation link" do
  #   location = stub(rels: { deactivation: "LINK"} )
  #   client.stub(location_res: stub(location: location))
  #   client.should_not_receive(:set_state).with(:activation, ext_key)
  #   client.activate(ext_key)
  # end

  # it "deactivates location" do
  #   client.stub(can_be_deactivated?: true)
  #   client.should_receive(:set_state).with(:deactivation, ext_key).and_return(nil)
  #   client.deactivate(ext_key)
  # end

  # it "doesn't deactivate location with no deactivation link" do
  #   location = stub(rels: { activation: "LINK"} )
  #   client.stub(location_res: stub(location: location))
  #   client.should_not_receive(:set_state).with(:deactivation, ext_key)
  #   client.deactivate(ext_key)
  # end

  # it "creates location" do
  #   VCR.use_cassette('location_creation') do
  #     ext_key = "8be69fdabf654aab5990d8e131c96f63"
  #     location_test["location"]['external_key'] = ext_key
  #     resp = client.create_location(location_test)
  #     location_test["location"]["state"] = "new"
  #     location_test["location"]["photos"] = []
  #     location_test["location"]["floor_plans"] = []
  #     resp.should == location_test["location"]
  #   end
  # end

  # it "updates location" do
  #   VCR.use_cassette('location_update') do
  #     location_test["location"]["title"] = "My test"
  #     resp = client.update_location(location_test)
  #     location_test["location"]["photos"].pop
  #     resp["photos"].pop
  #     resp.should == location_test["location"]
  #   end
  # end

end
