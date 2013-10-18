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

      private

      def contact_list_resource_agent
        LokalebasenApi::ResponseChecker.check(get_contacts) do |response|
          response.data
        end
      end

      def get_contacts
        root_resource.rels[:contacts].get
      end
    end
  end
end
