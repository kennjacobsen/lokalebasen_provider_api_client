require 'json'
require 'sawyer'
require 'map'
require 'forwardable'
require_relative 'contact_client'

module LokalebasenApi
  class Client
    include LokalebasenApi::Resource::HTTPMethodPermissioning
    include LokalebasenApi::ClientHelper
    extend Forwardable

    def_delegators :location_client, :locations, :location, :exists?,
                                     :create_location, :update_location,
                                     :deactivate, :activate, :create_photo,
                                     :update_photo,
                                     :delete_photo, :create_prospectus,
                                     :delete_prospectus, :create_floorplan,
                                     :delete_floorplan


    def_delegators :contact_client, :contacts, :find_contact_by_external_key,
                                    :create_contact, :update_contact_by_resource,
                                    :find_contact_by_email

    def_delegators :subscription_client, :create_subscription,
                                         :subscriptions_for_location,
                                         :delete_subscription

    attr_reader :logger, :agent

    # @param credentials [Hash] e.g. { :api_key => "03e7ad6c157dcfd1195144623d06ad0d2498e9ec" }
    # @param enable_logging [Boolean] specifies wether the client should log calls
    # @param service_url [String] URL to root of service e.g. http://IP_ADDRESS:3000/api/provider
    def initialize(credentials, service_url, options = {})
      @api_key     = credentials[:api_key]
      @service_url = service_url
      @logger      = options.fetch(:logger) { nil }
      @agent       = options.fetch(:agent) { default_agent}

      raise "api_key required" if @api_key.nil?
      raise "service_url required" if @service_url.nil?
    end

    # Deletes specified resource
    # @return [void]
    def delete_resource(resource)
      rel = resource.rels[:self]
      permit_http_method!(rel, :delete)
      response = rel.delete
      check_response(response)
    end

    # Sets state on the resource, by calling post on relation defined by relation_type
    # E.g. set_state(:deactivation, location_resource) #=> location
    # @param relation_type [Symbol] state e.g. :deactivation
    # @param resource [Sawyer::Resource] the resource to set state on
    # @return [Sawyer::Resource] response
    def set_state(relation_type, resource)
      relation = resource.rels[relation_type]
      permit_http_method!(relation, :post)
      response = relation.post
      check_response(response)
      response
    end

    private

      def subscription_client
        LokalebasenApi::SubscriptionClient.new
      end

      def location_client
        LokalebasenApi::LocationClient.new(agent)
      end

      def contact_client
        @contact_client ||= LokalebasenApi::ContactClient.new(agent)
      end

      def default_agent
        Sawyer::Agent.new(service_url) do |http|
          http.headers['Content-Type'] = 'application/json'
          http.headers['Api-Key'] = @api_key
        end
      end

      def service_url
        @service_url
      end

      def debug(message)
        if logger
          logger.debug("ProviderApiClient") { message }
        end
      end
  end

  class NotFoundException < StandardError
    def initialize(msg)
      super(msg)
    end
  end

end
