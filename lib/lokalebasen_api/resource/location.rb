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

      def find_by_external_key(external_key)
        location_resource_agent(external_key)
      end

      def exists?(external_key)
        all.any? {|location| location.external_key == external_key }
      end

      private

      def location_resource_agent(external_key)
        detect_location_from(all, external_key) do |location|
          LokalebasenApi::ResponseChecker.check(location.rels[:self].get) do |response|
            resource = response.data.location
            resource
          end
        end
      end

      def location_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_locations) do |response|
          resource = response.data
          resource
        end
      end

      def detect_location_from(locations, external_key)
        location = locations.detect { |location| location.external_key == external_key }
        if location.nil?
          raise LokalebasenApi::NotFoundException.new("Location with external_key '#{external_key}', not found!")
        end
        if block_given?
          yield location
        else
          location
        end
      end

      def get_locations
        root_resource.rels[:locations].get
      end
    end
  end
end
