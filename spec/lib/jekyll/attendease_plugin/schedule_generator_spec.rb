require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::ScheduleGenerator do

  before(:all) do
    @schedule_generator = find_generator(described_class)
    @date = @schedule_generator.event['dates'].first['date']
    @session_slug = Jekyll::AttendeasePlugin::EventDataGenerator.parameterize(@schedule_generator.sessions.first['name'], '_')
    @presenter_slug = @schedule_generator.presenters.first['slug']
    @venues_slug = Jekyll::AttendeasePlugin::EventDataGenerator.parameterize(@schedule_generator.venues.first['name'], '_') + '.html'
  end

  it 'creates a presenters index page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], 'index.html'))).to eq(true)
  end

  it 'creates a presenter page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to eq(true)
  end

  it 'creates a venue index page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], 'index.html'))).to eq(true)
  end

  it 'creates a venue page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @venues_slug))).to eq(true)
  end

  it 'creates a schedule index page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'index.html'))).to eq(true)
  end

  it 'creates a schedule day index page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @date, 'index.html'))).to eq(true)
    expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'index.html'))).to include 'attendease-session-and-instance'
  end

  it 'creates a schedule sessions index page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', 'index.html'))).to eq(true)
  end

  it 'creates a schedule session page' do
    expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug, 'index.html'))).to eq(true)
  end

  context 'presenter linking' do
    it 'links presenters correctly from the presenter index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], 'index.html'))).to include @presenter_slug
    end

    it 'links presenters correctly from the session page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug, 'index.html'))).to include @presenter_slug
    end

  end

  context 'in a site with attendease.show_day_index = true' do
    before(:all) do
      @site = build_site({ 'attendease' => { 'show_day_index' => true } })
    end

    it 'creates the day index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'index.html'))).to_not include 'attendease-session-and-instance'
    end
  end
end

