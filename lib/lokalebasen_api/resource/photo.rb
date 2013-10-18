module LokalebasenApi
  module Resource
    class Photo < Asset
      def initialize(location_resource)
        super(location_resource, :photos, :photos)
      end
    end
  end
end
