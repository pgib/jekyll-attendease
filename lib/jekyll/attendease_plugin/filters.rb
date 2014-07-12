module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        EventDataGenerator.parameterize(string, '_')
      end
    end
  end
end
