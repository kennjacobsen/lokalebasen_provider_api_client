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

    private

    def location_resource
      Resource::Location.new(root_resource)
    end

    def root_resource
      Resource::Root.new(agent).get
    end
  end
end
