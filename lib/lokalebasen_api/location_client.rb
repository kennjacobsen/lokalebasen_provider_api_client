module LokalebasenApi
  class LocationClient
    attr_reader :agent

    def initialize(agent)
      @agent = agent
    end

    # Returns all locations for the current provider
    # @return [Array<Map>] all locations
    def locations
      location_resource.all.map do |location|
        Mapper::Location.new(location).mapify
      end
    end

    # Returns specified location for the current provider
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @raise [RuntimeError] if location not found, e.g. "Location with external_key 'LOC_EXT_KEY', not found!"
    # @return [Map] location
    def location(location_ext_key)
      Mapper::Location.new(
        location_resource.find_by_external_key(location_ext_key)
      ).mapify
    end

    # Returns true if locations having location_ext_key exists
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Boolean] exists?
    def exists?(location_ext_key)
      location_resource.exists?(location_ext_key)
    end

    # @param location [Hash] e.g. { :location => { :title => "" .. } }
    # @return [Map] created location
    def create_location(location)
      Mapper::Location.new(
        location_resource.create(location)
      ).mapify
    end

     # @return [Map] updated location
    def update_location(location)
      Mapper::Location.new(
        location_resource.update(location["location"]["external_key"], location)
      ).mapify
    end

    # Deactivates the specified location
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Map] location
    def deactivate(external_key)
      Mapper::Location.new(
        location_resource.deactivate(external_key)
      ).mapify
    end

    # Activates the specified location
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Map] location
    def activate(external_key)
      Mapper::Location.new(
        location_resource.activate(external_key)
      ).mapify
    end

    private

    def location_resource
      Resource::Location.new(root_resource)
    end

    def root_resource
      Resource::Root.new(agent).get
    end
  end
end
