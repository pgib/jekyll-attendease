module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        Helpers.parameterize(string, '_')
      end
      def json(obj)
        obj.to_json
      end
    end
  end
end
