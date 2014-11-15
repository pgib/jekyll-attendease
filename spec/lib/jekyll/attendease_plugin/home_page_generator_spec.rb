require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::HomePageGenerator do

  context 'Using the default homepage template in the gem' do
    before do
      # Ensure no custom templates are being used.
      templates_json = File.join(@site.config['source'], '_attendease', 'data', 'templates.json')
      File.open(templates_json, 'w') { |file| file.write([].to_json) }
      @site = build_site
    end


    it 'creates the home page' do
      template_files = Dir.chdir(@template_root) { Dir.glob('*/**.html') }

      expect(File.exists?(File.join(@site.config['destination'], 'index.html'))).to eq(true)
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<h2>WHO</h2>"
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<div class=\"info\">#{@site.config['attendease']['data']['event_host']}</div>"
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<h2>WHEN</h2>"
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<div class=\"info\">#{@site.config['attendease']['data']['event_dates']}</div>"
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<h2>WHERE</h2>"
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<div class=\"info\">#{@site.config['attendease']['data']['event_location']}</div>"
    end
  end

  context 'Using a custom homepage template from the Attendease API' do
    before do
      templates_json = File.join(@site.config['source'], '_attendease', 'data', 'templates.json')

      templates = [
        {
          :data => "<h1>This is a custom homepage for Attendease</h1>",
          :id => "544e905b0bdb82e3ac000002",
          :page => 'index',
          :section => 'website'
        }
      ]

      File.open(templates_json, 'w') { |file| file.write(templates.to_json) }

      @site = build_site
    end

    it 'creates the home page' do
      template_files = Dir.chdir(@template_root) { Dir.glob('*/**.html') }

      expect(File.exists?(File.join(@site.config['destination'], 'index.html'))).to eq(true)
      expect(File.read(File.join(@site.config['destination'], 'index.html'))).to include "<h1>This is a custom homepage for #{@site.config['attendease']['data']['event_host']}</h1>"
    end
  end

end
