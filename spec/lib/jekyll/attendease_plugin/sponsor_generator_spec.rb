require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SponsorGenerator do

  it 'creates the sponsor listing page' do
    template_files = Dir.chdir(@template_root) { Dir.glob('*/**.html') }

    expect(File.exists?(File.join(@site.config['destination'], 'sponsors', 'index.html'))).to eq(true)
  end

end

