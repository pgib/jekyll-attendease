require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventDataGenerator do

  before(:all) do
    @event_data_generator = find_generator(described_class)
  end
  #pending 'downloads data and populates the site.config variable' do
  #end
  it 'populates a site wide presenters array' do
    expect(@site.config['attendease']['presenters'].class).to eq(Array)
    expect(@site.config['attendease']['presenters'].length).to eq(2)
  end

  it 'populates a site wide rooms array' do
    expect(@site.config['attendease']['rooms'].class).to eq(Array)
    expect(@site.config['attendease']['rooms'].length).to eq(1)
  end

  it 'populates a site wide sessions array' do
    expect(@site.config['attendease']['sessions'].class).to eq(Array)
    expect(@site.config['attendease']['sessions'].length).to eq(3)
  end

  it 'populates a site wide venues array' do
    expect(@site.config['attendease']['venues'].class).to eq(Array)
    expect(@site.config['attendease']['venues'].length).to eq(2)
  end

  it 'populates a site wide filters array' do
    expect(@site.config['attendease']['filters'].class).to eq(Array)
    expect(@site.config['attendease']['filters'].length).to eq(1)
  end

  it 'populates a site wide days array' do
    expect(@site.config['attendease']['days'].class).to eq(Array)
    expect(@site.config['attendease']['days'].length).to eq(2)
  end

  it 'populates a site wide sponsors array' do
    expect(@site.config['attendease']['sponsors'].class).to eq(Array)
    expect(@site.config['attendease']['sponsors'].length).to eq(1)
  end

  it 'populates a site wide event object' do
    expect(@site.config['attendease']['event'].class).to eq(Hash)
  end


end

