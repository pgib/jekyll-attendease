module Jekyll
  module AttendeasePlugin
    class SitePagesGenerator < Generator
      safe true

      def generate(site)
        site.config['attendease']['pages'].each do |page|
          site.pages << SitePage.new(site, site.source, page)

        end
      end
    end
  end
end
