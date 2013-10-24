module LokalebasenApi
  class SubscriptionClient
    def subscriptions_for_location(location_resource)
      Resource::Subscription.new(location_resource).all.map do |subscription|
        Mapper::Subscription.new(subscription).mapify
      end
    end

    def create_subscription(location_resource, contact_resource)
      subscription_params = { :contact => contact_resource.rels[:self].href }
      Mapper::Subscription.new(
        Resource::Subscription.new(location_resource).create(subscription_params)
      ).mapify
    end
  end
end
