module LokalebasenApi
  module Resource
    class Asset
      include LokalebasenApi::Resource::HTTPMethodPermissioning

      attr_reader :location_resource, :resource_name, :association_proxy

      def initialize(location_resource, resource_name, association_proxy)
        @location_resource = location_resource
        @resource_name     = resource_name
        @association_proxy = association_proxy
      end

      def create(photo_url, asset_ext_key, position=nil)
        data = asset_data(asset_ext_key, photo_url, position)
        post_response = location_resource.rels[resource_name].post(data)
        LokalebasenApi::ResponseChecker.check(post_response) do |response|
          response.data.job
        end
      end

      def update(asset_ext_key, position)
        data = asset_update_data(position)
        asset = get_asset_resource(asset_ext_key)
        LokalebasenApi::ResponseChecker.check(asset.rels[:self].put(data)).status
      end

      def delete(asset_ext_key)
        asset = get_asset_resource(asset_ext_key)
        LokalebasenApi::ResponseChecker.check(asset.rels[:self].delete).status
      end

      private

      def get_asset_resource(asset_ext_key)
        find_asset(asset_ext_key) do |asset|
          permit_http_method!(asset.rels[:self], :delete)
          permit_http_method!(asset.rels[:self], :put)
          asset
        end
      end

      def find_asset(asset_ext_key)
        asset = assets.detect{ |asset| asset.external_key == asset_ext_key }
        if asset.nil?
          raise NotFoundException, "#{self.class} with external_key "\
            "'#{asset_ext_key}', not found on #{location_resource.external_key}!"
        end
        yield asset
      end

      def assets
        return [] unless location_has_assets?
        result = location_resource.send(association_proxy)
        result = Array[result] unless result.kind_of?(Array)
        result
      end

      def location_has_assets?
        location_resource.respond_to?(association_proxy) &&
          !location_resource.send(association_proxy).nil?
      end

      def asset_data(asset_ext_key, photo_url, position)
        {
          asset_data_key => {
            external_key: asset_ext_key,
            url: photo_url,
            position: position
          }
        }
      end

      def asset_update_data(position)
        {
          asset_data_key => {
            position: position
          }
        }
      end

      def asset_data_key
        underscore(class_name_without_scopes).downcase.to_sym
      end

      def class_name_without_scopes
        self.class.name.split("::").last
      end

      def underscore(camel_cased_word)
        camel_cased_word.gsub(/([a-z\d])([A-Z])/,'\1_\2')
      end
    end
  end
end
