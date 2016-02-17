module Jekyll
  module AttendeasePlugin
    module Filters
      def slugify(string)
        Helpers.parameterize(string, '_')
      end

      def json(obj)
        obj.to_json
      end

      def safe_json(obj)
        obj = obj.to_json
        obj.gsub!(/[^\x00-\x7F]/,'')             # escape non-ascii
        obj.gsub!(/\\[nrt]/,'')                  # escape multiline
        obj.gsub!('\"','escaped-quotes')         # escape content quotes I
        obj.gsub!('"','\"')                      # escape quoting quotes
        obj.gsub!('escaped-quotes','\\\\\\\\\"') # escape content quotes II
        obj
      end
    end
  end
end
