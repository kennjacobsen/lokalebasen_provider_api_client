module LokalebasenApi
  module Resource
    class Location
      include LokalebasenApi::Resource::HTTPMethodPermissioning

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

      def create(location_params)
        create_response =
          location_list_resource_agent.rels[:self].post(location_params)
        LokalebasenApi::ResponseChecker.check(create_response) do |response|
          response.data.location
        end
      end

      def update(external_key, location_params)
        update_response = location_resource_agent(external_key).rels[:self].put(location_params)
        LokalebasenApi::ResponseChecker.check(update_response) do |response|
          response.data.location
        end
      end

      def deactivate(external_key)
        set_state_and_return_location(external_key, :deactivation)
      end

      def activate(external_key)
        set_state_and_return_location(external_key, :activation)
      end

      private

      def set_state_and_return_location(external_key, state)
        relation = location_resource_agent(external_key).rels[state]
        return unless relation
        LokalebasenApi::ResponseChecker.check(relation.post) do |response|
          response.data.location
        end
      end

      def location_resource_agent(external_key)
        detect_location_from(all, external_key) do |location|
          LokalebasenApi::ResponseChecker.check(location.rels[:self].get) do |response|
            resource = response.data.location
            permit_http_method!(resource.rels[:self], :put)
            permit_http_method!(resource.rels[:deactivation], :post)
            permit_http_method!(resource.rels[:activation], :post)
            resource
          end
        end
      end

      def location_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_locations) do |response|
          resource = response.data
          permit_http_method!(resource.rels[:self], :post)
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
