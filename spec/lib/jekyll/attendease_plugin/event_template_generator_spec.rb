require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventTemplateGenerator do

  it 'creates the Attendease template files' do
    template_files = Dir.chdir(File.join(@template_root, 'attendease')) { Dir.glob('**/**.html') }

    template_files.each do |template_file|
      path = File.join(@site.config['source'], '_attendease', 'templates', template_file)

      expect(File.exists?(path)).to eq(true)
      expect(File.size(path)).to be > 0
    end
  end

end

