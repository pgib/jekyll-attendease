require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePagesGenerator do
  let (:site) { build_site }
  let (:site_pages_generator) { find_generator(site, described_class) }
  let(:index_file) {  'index.html' }

  it 'creates a page using the provided slug' do
    slug = site.data['pages'].last['slug']
    file = File.join(site.config['destination'], slug, 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
    expect(File.read(file)).to include '<title>Test Page</title>'
  end

  it 'creates a block instance json file using the provided slug' do
    slug = site.data['pages'].last['slug']
    file = File.join(site.config['destination'], slug, 'index.json')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end
end
