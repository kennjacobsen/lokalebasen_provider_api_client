require 'spec_helper'

describe LokalebasenApi::Resource::Prospectus do

  # Shared specs can be found in spec/lib/support/shared_examples/asset.rb
  it_behaves_like "an asset", :prospectuses, :prospectus do
    let(:asset_resource) {
      LokalebasenApi::Resource::Prospectus.new(location_resource)
    }
  end
end
