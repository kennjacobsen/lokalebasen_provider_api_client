module LokalebasenApi
  module Resource
    class FloorPlan < Asset
      def initialize(location_resource)
        super(location_resource, :floor_plans, :floor_plans)
      end
    end
  end
end
