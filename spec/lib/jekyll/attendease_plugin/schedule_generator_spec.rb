require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::ScheduleGenerator do

  before(:all) do
    @schedule_generator = find_generator(described_class)
    @date = @schedule_generator.schedule_data.event['dates'].first['date']
    @index_file = 'index.html'
    @session_slug = @schedule_generator.schedule_data.sessions.first['slug']
    @presenter_slug = @schedule_generator.schedule_data.presenters.first['slug']
    @presenter_social = @schedule_generator.schedule_data.presenters.first['social']
    @venue_slug = @schedule_generator.schedule_data.venues.first['slug']
  end

  it 'creates a presenters index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a presenter page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @index_file)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule day index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @date, @index_file)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
    expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], @index_file))).to include 'attendease-session-and-instance'
  end

  it 'creates a schedule sessions index page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @index_file)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  it 'creates a schedule session page' do
    file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug)
    expect(File.exists?(file)).to eq(true)
    expect(File.file?(file)).to eq(true)
  end

  context 'with a localized name' do
    before do
      @session_slug_localized = @schedule_generator.schedule_data.sessions.last['slug']
      @presenter_slug_localized = @schedule_generator.schedule_data.presenters.last['slug']
      @venue_slug_localized = @schedule_generator.schedule_data.venues.last['slug']
    end

    it 'should use the session code' do
      expect(@session_slug_localized).to eq('420.html')
    end

    it 'creates a schedule session page for the name' do
      file = File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug_localized)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end

    it 'should use the presenter id' do
      expect(@presenter_slug_localized).to eq('53bc134b02c8bc9994000055.html')
    end

    it 'creates a presenter page' do
      file = File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug_localized)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end

    it 'should use the venue id' do
      expect(@venue_slug_localized).to eq('53bc120d02c8bc9994000032.html')
    end

    it 'creates a venue page' do
      file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @venue_slug_localized)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end
  end

  context 'presenter linking' do
    it 'links presenters correctly from the presenter index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file))).to include @presenter_slug
    end

    it 'links presenters correctly from the session page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug))).to include @presenter_slug
    end
  end

  context 'a single venue' do
    pending 'creates a venue index page' do
      file = File.join(@site.config['destination'], @site.config['attendease']['venue_path_name'], @index_file)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end
  end

  context 'multiple venues' do
    it 'creates a venue index page' do
      file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @index_file)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end

    it 'creates a venue page' do
      file = File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @venue_slug)
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end
  end

  context 'presenter social links' do
    it 'includes the included social links' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file))).to include "twitter.com/#{@presenter_social['twitter']}"
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file))).to include "facebook.com/#{@presenter_social['facebook']}"

      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to include "twitter.com/#{@presenter_social['twitter']}"
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to include "facebook.com/#{@presenter_social['facebook']}"
    end

    it 'does not include social links that are not there' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file))).to_not include "linkedin"
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @index_file))).to_not include "googleplus"

      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to_not include "linkedin"
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to_not include "googleplus"
    end
  end

  context 'venue linking' do
    it 'links venues correctly from the venue index page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['venues_path_name'], @index_file))).to include @venue_slug
    end

    it 'links venues correctly from the presenter page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['presenters_path_name'], @presenter_slug))).to include @venue_slug
    end

    it 'links venues correctly from the session page' do
      expect(File.read(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', @session_slug))).to include @venue_slug
    end
  end

  context 'in a site with attendease.show_schedule_index = true' do
    it 'creates the day index page and show schedule widget' do
      site = build_site({ 'attendease' => { 'show_schedule_index' => true } })
      expect(File.read(File.join(site.config['destination'], site.config['attendease']['schedule_path_name'], @index_file))).to include 'attendease-schedule-widget'
    end
  end

  context 'in a site with attendease.session_slug_uses_code = true' do
    it 'creates a schedule session page' do
      @site = build_site({ 'attendease' => { 'session_slug_uses_code' => true } })
      @schedule_generator = find_generator(described_class)
      session_slug = @schedule_generator.schedule_data.sessions.first['slug']

      expect(File.exists?(File.join(@site.config['destination'], @site.config['attendease']['schedule_path_name'], 'sessions', session_slug))).to eq(true)
    end
  end

  context 'in a site with the page paths set to nil' do
    it 'no schedule folder exists' do
      @site = build_site({ 'attendease' => { 'schedule_path_name' => nil } })

      expect(File.exists?(File.join(@site.config['destination'], 'schedule'))).to eq(false)
    end

    it 'no presenters folder exists' do
      @site = build_site({ 'attendease' => { 'presenters_path_name' => nil } })

      expect(File.exists?(File.join(@site.config['destination'], 'presenters'))).to eq(false)
    end

    it 'no venues folder exists' do
      @site = build_site({ 'attendease' => { 'venues_path_name' => nil, 'venue_path_name' => nil } })

      expect(File.exists?(File.join(@site.config['destination'], 'venues'))).to eq(false)
    end

    it 'no sponsors folder exists' do
      @site = build_site({ 'attendease' => { 'sponsors_path_name' => nil } })

      expect(File.exists?(File.join(@site.config['destination'], 'sponsors'))).to eq(false)
    end
  end

  it 'makes all data available to the entire site' do
    @site = build_site

    expect(@site.data['event']['id']).to eq('foobar')
    %w{ site templates event sessions presenters rooms filters venues sponsors lingo }.each do |key|
      expect(@site.data.include?(key)).to eq(true)
    end
  end
end
