require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePage do
  before(:all) do
    @site_page = find_page(described_class, Proc.new { |p| p.data['site_page']['slug'] == 'test' })
  end

  it 'fills the page zones with the rendered html' do
    expect(@site_page.data['dropzone1']).to eq('<h1>Hello world</h1>')
  end
end
