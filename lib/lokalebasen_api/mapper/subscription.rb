module LokalebasenApi
  module Mapper
    class Subscription
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def mapify
        res =  Map.new(resource)
        res = Map.new(res.to_hash) # Minor hack
        res.resource = resource
        res
      end
    end
  end
end
