require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventTemplateGenerator do
  context 'legacy event site' do
    let(:site) { build_site }

    it 'creates the Attendease template files' do
      template_files = Dir.chdir(File.join(@template_root, 'attendease')) { Dir.glob('**/**.html') }

      template_files.each do |template_file|
        path = File.join(site.config['attendease_source'], '_attendease', 'templates', template_file)

        puts path
        expect(File.exists?(path)).to eq(true)
        expect(File.size(path)).to be > 0
      end
    end
  end

  context 'CMS site' do
    let(:site) { build_cms_site }

    it 'skips creating the Attendease template files' do
      expect(Pathname.new(site.config['attendease_source']).join('templates').exist?).to eq(false)
    end
  end
end

