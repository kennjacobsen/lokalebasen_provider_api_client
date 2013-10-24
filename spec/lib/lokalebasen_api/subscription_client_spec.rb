require 'spec_helper'

describe LokalebasenApi::SubscriptionClient do
  let(:location_resource) { double("LocationResource")}
  let(:contact_resource) {
    double("ContactResource",
      :rels => {
        :self => double(href: "http://www.contact.dk/1")
      }
    )
  }
  let(:subscription_resource) { double("SubscriptionResource") }

  it "returns a list of mapified subscriptions for the given location" do
    subscriptions = [double("Subscription")]
    LokalebasenApi::Resource::Subscription.stub_chain(:new, :all).
      and_return(subscriptions)
    mapped_subscription = double("MappedSubscription")
    LokalebasenApi::Mapper::Subscription.stub_chain(:new, :mapify).
      and_return(mapped_subscription)
    LokalebasenApi::SubscriptionClient.new.
      subscriptions_for_location(location_resource).
      should =~ [mapped_subscription]
  end

  it "creates a sugsbscription by a given location resource and contact resource" do
    LokalebasenApi::Resource::Subscription.stub(:new).and_return(subscription_resource)
    subscription_params = { :contact => "http://www.contact.dk/1" }
    subscription_resource.should_receive(:create).
      with(subscription_params)
    LokalebasenApi::SubscriptionClient.new.
      create_subscription(location_resource, contact_resource)
  end

  it "returns a mapped version of the response after create" do
    LokalebasenApi::Resource::Subscription.stub_chain(:new, :create)
    mapped_subscription = double("MappedSubscription")
    LokalebasenApi::Mapper::Subscription.stub_chain(:new, :mapify).
      and_return(mapped_subscription)
    LokalebasenApi::SubscriptionClient.new.
      create_subscription(location_resource, contact_resource).
      should == mapped_subscription
  end
end
