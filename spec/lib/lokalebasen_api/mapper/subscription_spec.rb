require 'spec_helper'

describe LokalebasenApi::Mapper::Subscription do
  let(:subscription_resource) {
    double("SubscriptionResource", :to_hash => { :ext_key => "subscription_ext_key" })
  }

  it "mapifies a simple subscription resource" do
    expected_value = {
      :ext_key => "subscription_ext_key",
      :resource => subscription_resource
    }
    LokalebasenApi::Mapper::Location.new(subscription_resource).
      mapify.should == expected_value
  end
end
