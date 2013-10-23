module LokalebasenApi
  module Resource
    class Subscription
      attr_reader :location_resource

      def initialize(location_resource)
        @location_resource = location_resource
      end

      def create(subscription_params)
        create_response =
          location_resource.rels[:subscriptions].post(subscription_params)
        LokalebasenApi::ResponseChecker.check(create_response) do |response|
          response.data.subscription
        end
      end
    end
  end
end
