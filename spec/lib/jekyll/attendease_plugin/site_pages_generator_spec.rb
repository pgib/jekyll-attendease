require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePagesGenerator do
  before(:all) do
    @site_pages_generator = find_generator(described_class)
    @index_file = 'index.html'
  end

  it 'creates a page using the provided slug' do
    #require 'pry'
    #binding.pry
    slug = @site.data['pages'].last['slug']
    file = File.join(@site.config['destination'], slug, 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
    expect(File.read(file)).to include '<title>Test Page</title>'
  end

  it 'creates a block instance json file using the provided slug' do
    slug = @site.data['pages'].last['slug']
    file = File.join(@site.config['destination'], slug, 'index.json')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end
end
