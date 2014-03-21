module ProviderApiFixtures
  def root_fixture
    {
      :_links => {
        :locations => {:href => "/api/provider/locations" },
        :contacts => { :href => "/api/provider/contacts" }
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
          :floor_plans => { :href => "/api/provider/locations/123/floor_plans" },
          :subscriptions => { :href => "/api/provider/locations/123/subscriptions" }
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

  def contact_list_fixture
    {
      :_links => {
        :self => { :href => "/api/provider/contacts" }
      },
      :contacts => [
        {
          :_links => {
            :self => { :href => "/api/provider/contacts/123"}
          },
          :external_key => "contact_ext_key1"
        },
        {
          :_links => {
            :self => { :href => "/api/provider/contacts/456"}
          },
          :external_key => "contact_ext_key2"
        }
      ]
    }
  end

  def contact_fixture
    {
      :contact => {
        :_links => {
            :self => {
                :href => "http://lokalebasen.dev/api/provider/contacts/123"
            }
        },
        :name => "Sven Sved",
        :email => "svensved@egendomsmaegler.dk",
        :phone_number => "34437799",
        :external_key => "contact_ext_key1"
      }
    }
  end

  def contact_456_fixture
    {
      :contact => {
        :_links => {
            :self => {
                :href => "http://lokalebasen.dev/api/provider/contacts/456"
            }
        },
        :name => "Nis Hansen",
        :email => "nis@ejendomsmaegler.dk",
        :phone_number => "34437799",
        :external_key => "contact_ext_key89"
      }
    }
  end

  def subscription_list_fixture
    {
      :_links => {
        :self => {
          :href => "/api/provider/locations/123/subscriptions"
        },
      },
      :subscriptions => [
        {
          :_links => {
            :self => {
              :href => "/api/provider/subscriptions/123"
            },
            :contact => {
              :href => "/api/provider/contacts/123"
            }
          },
          :contact => "http://www.lokalebasen.dk/api/provider/contacts/123"
        },
        {
          :_links => {
            :self => {
              :href => "/api/provider/subscriptions/456"
            },
            :contact => {
              :href => "/api/provider/contacts/456"
            }
          },
          :contact => "http://www.lokalebasen.dk/api/provider/contacts/456"
        }
      ]
    }
  end

  def subscription_fixture
    {
      :subscription => {
        :_links => {
          :self => {
            :href => "/api/provider/subscriptions/123"
          },
          :contact => {
            :href => "/api/provider/contacts/123"
          },
          :location => {
            :href => "/api/provider/locations/123"
          }
        },
        :contact => "/api/provider/contacts/123"
      }
    }
  end

  def error_fixture(message = "Error Message")
    { :message => message }
  end
end
