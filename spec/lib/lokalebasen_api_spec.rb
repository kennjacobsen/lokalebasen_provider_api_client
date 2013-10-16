require 'spec_helper'

describe LokalebasenApi do
  it "returns a client with given arguments" do
    credentials = { :api_key => "MyApiKey"}
    url = "http://www.service_url.com"
    client = double("Client")
    LokalebasenApi::Client.stub(:new).and_return(client)
    LokalebasenApi.client(credentials, url).should == client
  end
end
