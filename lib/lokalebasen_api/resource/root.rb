module LokalebasenApi
  module Resource
    class Root
      attr_reader :agent

      def initialize(agent)
        @agent = agent
      end

      def get
        LokalebasenApi::ResponseChecker.check(agent.root) do |response|
          response.data
        end
      end
    end
  end
end
