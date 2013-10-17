module LokalebasenApi
  module Resource
    class Prospectus < Asset
      def initialize(location_resource)
        super(location_resource, :prospectuses, :prospectus)
      end
    end
  end
end
