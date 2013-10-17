require 'spec_helper'

describe LokalebasenApi::Mapper::Job do
  let(:self_href) { double("http://www.something.com") }
  let(:relation) { double("Self", :href_template => self_href) }
  let(:resource) {
    double("Resource",
      :to_hash => {
        :external_key => "ext_key"
      },
      :rels => {
        :self => relation
      }
    )
  }

  it "mapifies a resource" do
    expected_value = {
      :external_key => "ext_key",
      :url => self_href
    }
    LokalebasenApi::Mapper::Job.new(resource).mapify.should == expected_value
  end
end
