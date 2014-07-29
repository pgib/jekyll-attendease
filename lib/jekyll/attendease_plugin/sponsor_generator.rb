module Jekyll
  module AttendeasePlugin
    class SponsorGenerator < Generator
      safe true

      def generate(site)
        if site.config['attendease']['has_sponsors']
          @attendease_data_path = File.join(site.source, '_attendease', 'data')
          sponsors = JSON.parse(File.read("#{@attendease_data_path}/sponsors.json"))

          sponsor_levels = site.config['attendease']['event']['sponsor_levels']
          sponsor_levels.each do |level|
            level['sponsors'] = []
          end

          sponsors.each do |sponsor|
            level = sponsor_levels.select { |m| m['_id'] == sponsor['level_id'] }.first
            level['sponsors'] << sponsor
          end

          # make this available to any page that wants it
          site.config['attendease']['sponsor_levels'] = sponsor_levels

          # /sponsors pages.
          dir = site.config['attendease']['sponsors_path_name']

          unless dir.nil?
            site.pages << SponsorsIndexPage.new(site, site.source, File.join(dir), site.config['attendease']['sponsor_levels'])
          end

          #sponsors.each do |sponsor|
          #  site.pages << SponsorPage.new(site, site.source, File.join(dir, Helpers.parameterize(sponsor['name']) + '.html', '_'), sponsor)
          #end
        end
      end
    end
  end
end

