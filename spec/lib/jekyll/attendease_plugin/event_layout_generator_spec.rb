require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventLayoutGenerator do
  let(:site) { build_site }

  it 'creates the pre-compiled layout stubs' do
    %w{ layout register surveys }.each do |layout|
      expect(File.exists?(File.join(site.config['destination'], 'attendease_layouts', "#{layout}.html"))).to eq(true)
    end
  end

  it 'creates the pre-compiled email layout stubs' do
    %w{ layout }.each do |layout|
      expect(File.exists?(File.join(site.config['destination'], 'attendease_layouts', 'emails', "#{layout}.html"))).to eq(true)
    end
  end

end

