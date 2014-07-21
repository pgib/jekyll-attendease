require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventLayoutGenerator do

  it 'creates the layout stubs' do
    %w{ layout register schedule presenters venues sponsors }.each do |layout|
      expect(File.exists?(File.join(@site.source, '_attendease_layouts', "#{layout}.html"))).to eq(true)
    end
  end

end

