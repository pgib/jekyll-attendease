require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SponsorGenerator do
  context 'event site' do
    let (:site) { build_site }

    it 'creates the sponsor listing page' do
      expect(File.exists?(File.join(site.config['destination'], 'sponsors', 'index.html'))).to eq(true)
      expect(File.read(File.join(site.config['destination'], 'sponsors', 'index.html'))).to include "<h1>Sponsors</h1>"
    end
  end

  context 'organization site' do
    let (:org_site) { build_org_site }

    it 'does not create the sponsor listing page' do
      expect(File.exists?(File.join(org_site.config['destination'], 'sponsors', 'index.html'))).to eq(false)
    end
  end

end

