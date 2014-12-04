module Jekyll
  module AttendeasePlugin
    class HomePageGenerator < Generator
      safe true

      def generate(site)
        site.pages << HomePage.new(site, site.source, File.join(''))
      end
    end
  end
end

