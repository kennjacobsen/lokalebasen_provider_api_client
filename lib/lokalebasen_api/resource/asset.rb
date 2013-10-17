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

      def create(photo_url, asset_ext_key)
        data = asset_data(asset_ext_key, photo_url)
        post_response = location_resource.rels[resource_name].post(data)
        LokalebasenApi::ResponseChecker.check(post_response) do |response|
          response.data.job
        end
      end

      def delete(asset_ext_key)
        asset = get_asset_resource(asset_ext_key)
        LokalebasenApi::ResponseChecker.check(asset.rels[:self].delete)
      end

      private

      def get_asset_resource(asset_ext_key)
        find_asset(asset_ext_key) do |asset|
          permit_http_method!(asset.rels[:self], :delete)
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
        Array(location_resource.send(association_proxy))
      end

      def location_has_assets?
        location_resource.respond_to?(association_proxy) &&
          !location_resource.send(association_proxy).nil?
      end

      def asset_data(asset_ext_key, photo_url)
        {
          asset_data_key => {
            external_key: asset_ext_key,
            url: photo_url
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
