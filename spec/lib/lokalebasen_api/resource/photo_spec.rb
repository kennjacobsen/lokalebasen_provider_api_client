require 'spec_helper'

describe LokalebasenApi::Resource::Photo do

  # Shared specs can be found in spec/lib/support/shared_examples/asset.rb
  it_behaves_like "an asset", :photos, :photo do
    let(:asset_resource) {
      LokalebasenApi::Resource::Photo.new(location_resource)
    }
  end
end
