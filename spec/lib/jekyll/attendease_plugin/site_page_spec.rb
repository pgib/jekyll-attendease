require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePage do
  let(:site) { build_site }
  let(:site_page) { find_page(site, described_class, Proc.new { |p| p.data['site_page']['slug'] == 'test' }) }

  it 'generates an index page in a folder matching the slug' do
    expect(File.exists?(File.join(site.config['destination'], site_page.dir, site_page.name))).to eq(true)
  end
end
