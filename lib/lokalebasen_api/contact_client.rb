require 'json'
require 'sawyer'
require 'map'
require_relative 'client_helper'

module LokalebasenApi
  class ContactClient
    include ClientHelper

    attr_accessor :agent

    def initialize(agent)
      @agent = agent
    end

    # Returns all contacts for the current provider
    # @return [Array<Map>] all contacts
    def contacts
      contact_resource.all.map do |contact|
        Mapper::Contact.new(contact).mapify
      end
    end

    # Returns specified contact for the current provider identified by
    # the external key
    # @param external_key [String] external_key for contact guid e.g. "39PQ32KUC6BSC3AS"
    # @raise [RuntimeError] if context not found, e.g. "Contact with external_key 'CON_EXT_KEY', not found!"
    # @return [Map] contact
    def find_contact_by_external_key(external_key)
      Mapper::Contact.new(
        contact_resource.find_by_external_key(external_key)
      ).mapify
    end

    private

      def contact_resource
        Resource::Contact.new(root_resource)
      end

      def root_resource
        Resource::Root.new(agent).get
      end
  end
end
