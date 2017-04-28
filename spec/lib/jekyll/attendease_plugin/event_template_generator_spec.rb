require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventTemplateGenerator do
  context 'event site' do
    let(:site) { build_site }

    it 'creates the Attendease template files' do
      template_files = Dir.chdir(File.join(@template_root, 'attendease')) { Dir.glob('**/**.html') }

      template_files.each do |template_file|
        path = File.join(site.config['source'], '_attendease', 'templates', template_file)

        expect(File.exists?(path)).to eq(true)
        expect(File.size(path)).to be > 0
      end
    end
  end

  context 'organization site' do
    let(:site) { build_org_site }

    it 'creates the Attendease template files' do
      template_files = Dir.chdir(File.join(@template_root, 'attendease')) { Dir.glob('**/**.html') }

      template_files.each do |template_file|
        path = File.join(site.config['source'], '_attendease', 'templates', template_file)

        expect(File.exists?(path)).to eq(true)
        expect(File.size(path)).to be > 0
      end
    end
  end
end

