module LokalebasenApi
  module Resource
    class Subscription
      include LokalebasenApi::Resource::HTTPMethodPermissioning
      attr_reader :location_resource

      def initialize(location_resource)
        @location_resource = location_resource
      end

      def all
        subscription_list_resource_agent.subscriptions
      end

      def create(subscription_params)
        create_response =
          location_resource.rels[:subscriptions].post(subscription_params)
        LokalebasenApi::ResponseChecker.check(create_response) do |response|
          response.data.subscription
        end
      end

      def delete(subscription_resource)
        permit_http_method!(subscription_resource.rels[:self], :delete)
        LokalebasenApi::ResponseChecker.check(subscription_resource.rels[:self].delete).status
      end

      private

      def subscription_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_subscriptions) do |response|
          response.data
        end
      end

      def get_subscriptions
        location_resource.rels[:subscriptions].get
      end
    end
  end
end
