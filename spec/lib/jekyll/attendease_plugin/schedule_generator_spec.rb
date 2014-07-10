require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::ScheduleGenerator do

  before(:all) do
    @schedule_generator = find_generator(described_class)
    @date = @schedule_generator.event['dates'].first['date']
    @session_slug = @schedule_generator.sessions.first['slug']
    @presenter_slug = @schedule_generator.presenters.first['slug']
    @venue_slug = Jekyll::AttendeasePlugin::EventDataGenerator.parameterize(@schedule_generator.venues.first['name'], '_') + '.html'
  end

  it 'creates a presenters index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a presenter page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a venue index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a venue page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @venue_slug)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule day index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @date, 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
    expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'index.html'))).to include 'attendease-session-and-instance'
  end

  it 'creates a schedule sessions index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', 'index.html')
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule session page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  context 'presenter linking' do
    it 'links presenters correctly from the presenter index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], 'index.html'))).to include @presenter_slug
    end

    it 'links presenters correctly from the session page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug))).to include @presenter_slug
    end
  end

  context 'venue linking' do
    it 'links venues correctly from the venue index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], 'index.html'))).to include @venue_slug
    end

    it 'links venues correctly from the presenter page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to include @venue_slug
    end

    it 'links venues correctly from the session page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug))).to include @venue_slug
    end
  end


  context 'in a site with attendease.show_day_index = true' do
    it 'creates the day index page' do
      site = build_site({ 'attendease' => { 'show_day_index' => true } })
      expect(File.read(File.join(site.config['destination'], site.config['attendease']['schedule_path_name'], 'index.html'))).to_not include 'attendease-session-and-instance'
    end
  end

  context 'in a site with attendease.session_slug_uses_code = true' do
    it 'creates a schedule session page' do
      @site = build_site({ 'attendease' => { 'session_slug_uses_code' => true } })
      @schedule_generator = find_generator(described_class)
      session_slug = @schedule_generator.sessions.first['slug']

      expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', session_slug))).to eq(true)
    end
  end
end

