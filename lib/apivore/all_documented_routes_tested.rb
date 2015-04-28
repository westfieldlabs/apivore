module Apivore
  class AllDocumentedRoutesTested

    def matches?(swagger_checker)
      @errors = []
      swagger_checker.mappings.each do |path, methods|
        methods.each do |method, codes|
          codes.each do |code|
            @errors << "#{method} #{path} is undocumented for response codes #{code}"
          end
        end
      end

      @errors.empty?
    end

    def description
      "have tested all documented routes"
    end

    def failure_message
      @errors.join("\n")
    end
  end
end
