module LokalebasenApi
  class ResponseChecker
    attr_reader :response

    class << self
      def check(response, &block)
        new(response).check(&block)
      end
    end

    def initialize(response)
      @response = response
    end

    def check
      case response.status
        when (400..499) then (fail "Error occured -> #{response.data.message}")
        when (500..599) then (fail "Server error -> #{error_msg(response)}")
      end
      if block_given?
        yield response
      else
        response
      end
    end

    private

    def error_msg(response)
      if response.data.index("html")
        "Server returned HTML in error"
      else
        response.data
      end
    end
  end
end
