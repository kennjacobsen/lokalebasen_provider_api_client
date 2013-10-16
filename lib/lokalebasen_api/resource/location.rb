module LokalebasenApi
  module Resource
    class Location
      attr_reader :root_resource

      def initialize(root_resource)
        @root_resource = root_resource
      end

      def all
        location_list_resource_agent.locations
      end

      private

      def location_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_locations) do |response|
          resource = response.data
          resource
        end
      end

      def get_locations
        root_resource.rels[:locations].get
      end
    end
  end
end
