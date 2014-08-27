require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::PreZeroPointSixLinkRedirectGenerator do

  context 'in a site with config.attendease.redirect_ugly_urls = true' do
    before(:all) do
      @site = build_site({ 'attendease' => { 'redirect_ugly_urls' => true } })
      @schedule_generator = find_generator(Jekyll::AttendeasePlugin::ScheduleGenerator)
    end

    it 'creates a redirect file from the old presenter.id URL to the new slug' do
      file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @schedule_generator.schedule_data.presenters.first['id'], 'index.html')

      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
      expect(File.read(file)).to include @schedule_generator.schedule_data.presenters.first['slug']
      expect(File.read(file)).to_not include 'My awesome'
    end

    it 'creates a redirect file from the old venue.id URL to the new slug' do
      file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @schedule_generator.schedule_data.venues.first['id'], 'index.html')

      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
      expect(File.read(file)).to include @schedule_generator.schedule_data.venues.first['slug']
      expect(File.read(file)).to_not include 'My awesome'
    end

    it 'creates a redirect file from the old session.code URL to the new slug' do
      file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @schedule_generator.schedule_data.sessions.first['code'], 'index.html')

      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
      expect(File.read(file)).to include @schedule_generator.schedule_data.sessions.first['slug']
      expect(File.read(file)).to_not include 'My awesome'
    end
  end

end

