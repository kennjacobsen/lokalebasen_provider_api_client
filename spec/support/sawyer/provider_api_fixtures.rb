module ProviderApiFixtures
  def root_fixture
    {
      :_links => {
        :locations => {:href => "/api/provider/locations" }
      }
    }
  end

  def location_fixture
    {
      :location => {
        :_links => {
          :self => { :href => "/api/provider/locations/123" },
          :activation => { :href => "/api/provider/locations/123/activations" },
          :deactivation => { :href => "/api/provider/locations/123/deactivations"},
          :photos => { :href => "/api/provider/locations/123/photos" },
          :prospectuses => { :href => "/api/provider/locations/123/prospectuses" },
          :floor_plans => { :href => "/api/provider/locations/123/floor_plans" }
        },
        :external_key => "location_ext_key",
        :photos => [
          {
            :_links => {
              :self => {
                :href => "/api/provider/photos/1"
              }
            },
            :external_key => "photos_external_key1"
          }
        ],
        :floor_plans => [
          {
            :_links => {
              :self => {
                :href => "/api/provider/floor_plans/1"
              }
            },
            :external_key => "floor_plans_external_key1"
          }
        ],
        :prospectus => {
          :_links => {
            :self => {
              :href => "/api/provider/prospectuses/1"
            }
          },
          :external_key => "prospectuses_external_key1"
        }
      }
    }
  end

  def location_list_fixture
    {
      :_links => {
        :self => { :href => "/api/provider/locations" }
      },
      :locations => [
        {
          :_links => {
            :self => { :href => "/api/provider/locations/123" }
          },
          :external_key => "location_ext_key"
        },
        {
          :_links => {
            :self => { :href => "/api/provider/locations/1234" }
          },
          :external_key => "location_ext_key2"
        }
      ]
    }
  end

  def asset_job_fixture
    {
      :job => {
        :_links => {
          :self => { :href => "http://host.com/api/provider/asset_jobs/123" }
        },
        :state => "enqueued"
      }
    }
  end

  def error_fixture(message = "Error Message")
    { :message => message }
  end
end
