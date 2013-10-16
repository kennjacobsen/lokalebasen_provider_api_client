module LokalebasenApi
  module Resource
    module HTTPMethodPermissioning

      private

      # PATCH: Because Lokalebasen API relations URLs do not include possible REST methods, Sawyer defaults to :get only.
      # This methods adds a REST method to the relation
      # @!visibility private
      # @param method [Symbol] - :put, :post, :delete
      # @return [Sawyer::Relation] patched relation
      def permit_http_method!(relation, method)
        unless relation.nil?
          relation.instance_variable_get(:@available_methods).add(method)
        end
      end
    end
  end
end
