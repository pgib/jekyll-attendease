module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        Helpers.parameterize(string, '_')
      end
    end
  end
end
