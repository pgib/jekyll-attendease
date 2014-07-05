module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        EventData.parameterize(string, '_')
      end
    end
  end
end
