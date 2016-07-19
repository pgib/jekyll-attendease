module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        Helpers.parameterize(string, '_')
      end

      def json(obj)
        obj.to_json
      end

      def awesome_inspect(obj)
        require 'awesome_print'
        obj.ai(html: true)
      end
    end
  end
end
