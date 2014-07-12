require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventDataGenerator do

  it 'creates the Attendease stub pages' do
    template_files = Dir.chdir(@template_root) { Dir.glob('*/**.html') }

    template_files.each do |template_file|
      path = File.join(@site.config['source'], '_attendease', 'templates', template_file)
      expect(File.exists?(path)).to eq(true)
      expect(File.size(path)).to > 0
    end
  end

end

