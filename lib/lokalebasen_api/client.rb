require 'json'
require 'sawyer'
require 'map'

module LokalebasenApi
  class Client

    # @param credentials [Hash] e.g. { :api_key => "03e7ad6c157dcfd1195144623d06ad0d2498e9ec" }
    # @param enable_logging [Boolean] specifies wether the client should log calls
    # @param service_url [String] URL to root of service e.g. http://IP_ADDRESS:3000/api/provider
    def initialize(credentials, enable_logging, service_url)
      @api_key = credentials[:api_key]
      @enable_logging = enable_logging
      @service_url = service_url

      raise "api_key required" if @api_key.nil?
      raise "service_url required" if @service_url.nil?
    end

    # Returns all locations for the current provider
    # @return [Array<Map>] all locations
    def locations
      locations_res.data.locations.map {|loc| location_res_to_map(loc)}
    end

    # Returns specified location for the current provider
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @raise [RuntimeError] if location not found, e.g. "Location with external_key 'LOC_EXT_KEY', not found!"
    # @return [Map] location
    def location(location_ext_key)
      loc = location_res(location_ext_key)
      location_res_to_map(loc.location)
    end

    # Returns true if locations having location_ext_key exists
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Boolean] exists?
    def exists?(location_ext_key)
      locations.any?{ |location| location[:external_key] == location_ext_key }
    end

    # @param location [Hash] e.g. { :location => { :title => "" .. } }
    # @return [Map] created location
    def create_location(location)
      locs = locations_res.data
      rel = add_method(locs.rels[:self], :post)
      response = rel.post(location)
      check_response(response)
      location_res_to_map(response.data.location)
    end

    # @return [Map] updated location
    def update_location(location)
      loc_res = location_res(location["location"]["external_key"]).location
      rel = add_method(loc_res.rels[:self], :put)
      response = rel.put(location)
      check_response(response)
      location_res_to_map(response.data.location)
    end

    # Deactivates the specified location
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Map] location
    def deactivate(location_ext_key)
      set_state(:deactivation, location_ext_key) if can_be_deactivated?(location_ext_key)
    end

    # Activates the specified location
    # @param location_ext_key [String] external_key for location guid e.g. "39PQ32KUC6BSC3AS"
    # @return [Map] location
    def activate(location_ext_key)
      set_state(:activation, location_ext_key) if can_be_activated?(location_ext_key)
    end

    # Creates a photo create background job on the specified location
    # @return [Map] created job
    def create_photo(photo_url, photo_ext_key, location_ext_key)
      loc = location_res(location_ext_key).location
      rel = add_method(loc.rels[:photos], :post)
      response = rel.post(photo_data(photo_ext_key, photo_url))
      check_response(response)
      res = response.data.job.to_hash
      res[:url] = response.data.job.rels[:self].href_template
      Map.new(res)
    end

    # Deletes specified photo
    # @raise [RuntimeError] if Photo not found, e.g. "Photo with external_key 'PHOTO_EXT_KEY', not found!"
    # @return [void]
    def delete_photo(photo_ext_key, location_ext_key)
      rel = photo(photo_ext_key, location_ext_key).rels[:self]
      add_method(rel, :delete)
      response = rel.delete
      check_response(response)
    end

    # Creates a floorplan create background job on the specified location
    # @return [Map] created job
    def create_floorplan(floorplan_url, floorplan_ext_key, location_ext_key)
      loc = location_res(location_ext_key).location
      rel = add_method(loc.rels[:floor_plans], :post)
      response = rel.post(floorplan_data(floorplan_ext_key, floorplan_url))
      check_response(response)
      res = response.data.job.to_hash
      res[:url] = response.data.job.rels[:self].href_template
      Map.new(res)
    end

    # Deletes specified floorplan
    # @raise [RuntimeError] if Floorplan not found, e.g. "Floorplan with external_key 'FLOORPLAN_EXT_KEY', not found!"
    # @return [void]
    def delete_floorplan(floorplan_ext_key, location_ext_key)
      rel = floorplan(floorplan_ext_key, location_ext_key).rels[:self]
      add_method(rel, :delete)
      response = rel.delete
      check_response(response)
    end

    private

      def can_be_activated?(location_ext_key)
        loc = location_res(location_ext_key).location
        !loc.rels[:activation].nil?
      end

      def can_be_deactivated?(location_ext_key)
        loc = location_res(location_ext_key).location
        !loc.rels[:deactivation].nil?
      end

      def check_response(response)
        case response.status
          when (400..499) then (fail "Error occured -> #{response.data.message}")
          when (500..599) then (fail "Server error -> #{error_msg(response)}")
          else nil
        end
      end

      def error_msg(response)
        if response.data.index("html")
          "Server returned HTML in error"
        else
          data
        end
      end

      def location_res(location_ext_key)
        location = locations_res.data.locations.detect { |location| location.external_key == location_ext_key }
        raise NotFoundException.new("Location with external_key '#{location_ext_key}', not found!") if location.nil?
        location.rels[:self].get.data
      end

      def locations_res
        root = agent.start
        check_response(root)
        locations_rel = root.data.rels[:locations]
        locations_rel.get
      end

      def floorplan(floorplan_ext_key, location_ext_key)
        loc = location_res(location_ext_key)
        floorplan = loc.location.floor_plans.detect{|floorplan| floorplan.external_key == floorplan_ext_key }
        raise NotFoundException.new("Floorplan with external_key '#{floorplan_ext_key}', not found!") if floorplan.nil?
        floorplan
      end

      def photo(photo_ext_key, location_ext_key)
        loc = location_res(location_ext_key)
        photo = loc.location.photos.detect{|photo| photo.external_key == photo_ext_key }
        raise NotFoundException.new("Photo with external_key '#{photo_ext_key}', not found!") if photo.nil?
        photo
      end

      # PATCH: Because Lokalebasen API relations URLs do not include possible REST methods, Sawyer defaults to :get only.
      # This methods adds a REST method to the relation
      # @!visibility private
      # @param method [Symbol] - :put, :post, :delete
      # @return [Sawyer::Relation] patched relation
      def add_method(relation, method)
        relation.instance_variable_get(:@available_methods).add(method)
        relation
      end

      def agent
        Sawyer::Agent.new(service_url) do |http|
          http.headers['Content-Type'] = 'application/json'
          http.headers['Api-Key'] = @api_key
        end
      end

      def set_state(rel, location_ext_key)
        loc = location_res(location_ext_key).location
        rel = add_method(loc.rels[rel], :post)
        response = rel.post
        check_response(response)
        location_res_to_map(response.data.location)
      end

      def photo_data(photo_ext_key, photo_url)
        {
          photo: {
            external_key: photo_ext_key,
            url: photo_url
          }
        }
      end

      def floorplan_data(floorplan_ext_key, floorplan_url)
        {
          floor_plan: {
            external_key: floorplan_ext_key,
            url: floorplan_url
          }
        }
      end

      def location_res_to_map(loc_res)
        res =  Map.new(loc_res)
        res.floor_plans = res.floor_plans.map{|fp| fp.to_hash} if res.has?(:floor_plans)
        res.photos = res.photos.map{|p| p.to_hash} if res.has?(:photos)
        Map.new(res.to_hash) # Minor hack
      end

      def service_url
        @service_url
      end
  end

  class NotFoundException < StandardError
    def initialize(msg)
      super(msg)
    end
  end

end
