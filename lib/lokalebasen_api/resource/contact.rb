module LokalebasenApi
  module Resource
    class Contact
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

      private

      def contact_resource_agent_by_external_key(external_key)
        find_contact_from_contact_list(external_key) do |contact|
          LokalebasenApi::ResponseChecker.check(contact.rels[:self].get) do |response|
            response.data.contact
          end
        end
      end

      def contact_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_contacts) do |response|
          response.data
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
