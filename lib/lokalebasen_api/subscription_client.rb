module LokalebasenApi
  class SubscriptionClient
    def create_subscription(location_resource, contact_resource)
      subscription_params = { :contact => contact_resource.rels[:self].href }
      Mapper::Subscription.new(
        Resource::Subscription.new(location_resource).create(subscription_params)
      ).mapify
    end
  end
end
