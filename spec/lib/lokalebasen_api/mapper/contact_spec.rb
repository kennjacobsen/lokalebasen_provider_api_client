require 'spec_helper'

describe LokalebasenApi::Mapper::Contact do
  let(:contact_resource) {
    double("ContactResource", :to_hash => { :ext_key => "contact_ext_key" })
  }

  it "mapifies a simple contact resource" do
    expected_value = {
      :ext_key => "contact_ext_key",
      :resource => contact_resource
    }
    LokalebasenApi::Mapper::Location.new(contact_resource).
      mapify.should == expected_value
  end
end
