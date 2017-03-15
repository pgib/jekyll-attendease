module Jekyll
  module AttendeasePlugin
    class SponsorGenerator < Generator
      safe true

      def generate(site)
        if site.config['attendease']['has_sponsors'] && site.config['attendease']['generate_sponsor_pages']
          sponsors = site.data['sponsors']

          sponsor_levels = site.config['attendease']['event']['sponsor_levels']
          sponsor_levels.each do |level|
            level['sponsors'] = []
          end

          sponsors.each do |sponsor|
            level = sponsor_levels.select do |m|
              key = 'id'
              key = '_id' if m[key].nil?
              m[key] == sponsor['level_id']
            end.first
            level['sponsors'] << sponsor
          end

          # make this available to any page that wants it
          site.config['attendease']['sponsor_levels'] = sponsor_levels

          # /sponsors pages.
          dir = site.config['attendease']['sponsors_path_name']

          if dir
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
