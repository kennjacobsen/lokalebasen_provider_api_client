module LokalebasenApi
  module Resource
    class Contact
      include LokalebasenApi::Resource::HTTPMethodPermissioning

      attr_reader :root_resource

      def initialize(root_resource)
        @root_resource = root_resource
      end

      def all
        contact_list_resource_agent.contacts
      end

      def find_by_external_key(external_key)
        contact_resource_agent_by_external_key(external_key)
      end

      def create(contact_params)
        create_response =
          contact_list_resource_agent.rels[:self].post(contact_params)
        LokalebasenApi::ResponseChecker.check(create_response) do |response|
          response.data.contact
        end
      end

      def update_by_resource(resource, contact_params)
        update_response =
          contact_resource_agent_by_resource(resource).rels[:self].put(contact_params)
        LokalebasenApi::ResponseChecker.check(update_response) do |response|
          response.data.contact
        end
      end

      private

      def contact_resource_agent_by_external_key(external_key)
        find_contact_from_contact_list(external_key) do |contact|
          contact_resource_agent_by_resource(contact)
        end
      end

      def contact_resource_agent_by_resource(resource)
        LokalebasenApi::ResponseChecker.check(resource.rels[:self].get) do |response|
          contact_resource = response.data.contact
          permit_http_method!(contact_resource.rels[:self], :put)
          contact_resource
        end
      end

      def contact_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_contacts) do |response|
          resource = response.data
          permit_http_method!(resource.rels[:self], :post)
          resource
        end
      end

      def find_contact_from_contact_list(external_key)
        contact = all.detect { |contact| contact.external_key == external_key }
        if contact.nil?
          raise LokalebasenApi::NotFoundException.new("Contact with external_key '#{external_key}', not found!")
        end
        yield contact
      end

      def get_contacts
        root_resource.rels[:contacts].get
      end
    end
  end
end
