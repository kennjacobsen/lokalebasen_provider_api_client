require 'spec_helper'

describe LokalebasenApi::Resource::FloorPlan do

  # Shared specs can be found in spec/lib/support/shared_examples/asset.rb
  it_behaves_like "an asset", :floor_plans, :floor_plan do
    let(:asset_resource) {
      LokalebasenApi::Resource::FloorPlan.new(location_resource)
    }
  end
end
