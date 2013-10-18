require 'spec_helper'

describe LokalebasenApi::Resource::Root do
  it "returns data from the response returned by ResponseChecker" do
    agent = double("Agent").as_null_object
    data = double("Data")
    response = double("Response", data: data)
    LokalebasenApi::ResponseChecker.stub(:check).and_yield(response)
    LokalebasenApi::Resource::Root.new(agent).get.should == data
  end
end
