require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePage do
  let(:site) { build_site }
  let(:site_page) { find_page(site, described_class, Proc.new { |p| p.data['site_page']['slug'] == 'test' }) }

  pending 'fills the page zones with the rendered html' do
    expect(site_page.data['dropzone1']).to eq('<h1>Hello world</h1>')
  end
end
