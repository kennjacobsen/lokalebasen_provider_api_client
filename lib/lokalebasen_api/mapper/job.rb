module LokalebasenApi
  module Mapper
    class Job
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def mapify
        response_hash = resource.to_hash
        response_hash[:url] = resource.rels[:self].href_template
        Map.new(response_hash)
      end
    end
  end
end
