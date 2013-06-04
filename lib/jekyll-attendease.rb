require 'httparty'
require 'json'

module Jekyll
  module Attendease

    class EventData < Generator
      safe true

      def generate(site)
        if attendease_config = site.config['attendease']

          if attendease_config['api_host'] && !attendease_config['api_host'].match(/^http(.*).attendease.com/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if attendease_config['api_host'][-1, 1] != '/'
              attendease_config['api_host'] += '/'
            end

            attendease_data_path = "#{site.config['source']}/_attendease_data"

            FileUtils.mkdir_p(attendease_data_path)

            update_data = true

            if File.exists?("#{attendease_data_path}/site.json")
              if (Time.now.to_i - File.mtime("#{attendease_data_path}/site.json").to_i) <= 30 # file is less than 30 seconds old
                update_data = false

                site_json = File.read("#{attendease_data_path}/site.json")

                event_data = JSON.parse(site_json)
              end
            end

            if update_data
              event_data = HTTParty.get("#{attendease_config['api_host']}api/site.json")

              if !event_data['error']
                puts "                    [Attendease] Saving event data..."

                File.open("#{attendease_data_path}/site.json", 'w+') { |file| file.write(event_data.parsed_response.to_json) }
              else
                raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
              end


              # Registration test pages, so we can style the forms!
              pages_to_fetch = ['choose_pass', 'checkout', 'dashboard']

              pages_to_fetch.each do |page|
                page_data = HTTParty.get("#{attendease_config['api_host']}attendease/preview/#{page}.html")

                if page_data.response.code.to_i == 200
                  puts "                    [Attendease] Saving test data for register page (#{page})..."

                  File.open("#{attendease_data_path}/attendease_test_register_#{page}.html", 'w+') { |file| file.write(page_data.parsed_response) }
                else
                  raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
                end
              end

              # Schedule test pages, so we can style the forms!
              pages_to_fetch = ['schedule', 'session']

              pages_to_fetch.each do |page|
                page_data = HTTParty.get("#{attendease_config['api_host']}attendease/preview/#{page}.html")

                if page_data.response.code.to_i == 200
                  puts "                    [Attendease] Saving test data for schedule page (#{page})..."

                  File.open("#{attendease_data_path}/attendease_test_#{page}.html", 'w+') { |file| file.write(page_data.parsed_response) }
                else
                  raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
                end
              end

              # Presenter test pages, so we can style the forms!
              pages_to_fetch = ['presenters', 'presenter']

              pages_to_fetch.each do |page|
                page_data = HTTParty.get("#{attendease_config['api_host']}attendease/preview/#{page}.html")

                if page_data.response.code.to_i == 200
                  puts "                    [Attendease] Saving test data for presenter page (#{page})..."

                  File.open("#{attendease_data_path}/attendease_test_#{page}.html", 'w+') { |file| file.write(page_data.parsed_response) }
                else
                  raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
                end
              end
            end

            # Adding to site config so we can access these variables globally wihtout using a Liquid Tag so we can use if/else
            site.config['attendease']['data'] = {}

            event_data.keys.each do |tag|
              site.config['attendease']['data'][tag] = event_data[tag]
            end
          end

        else
          raise "Please set the Attendease event data in your _config.yml"
        end
      end
    end


    class EventThemes < Generator
      safe true

      def generate(site)
        puts "                    [Attendease] Generating theme layouts..."

        attendease_precompiled_theme_layouts_path = "#{site.config['source']}/attendease_layouts"

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        layouts_to_precompile = ['layout', 'register', 'schedule', 'presenters']

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?("#{site.config['source']}/_layouts/layout.html")

            # create a layout file if is already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presnters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            if !File.exists?("#{site.config['source']}/attendease_layouts/#{layout}.html")
              theme_layout_content = <<-eos
---
layout: layout
---

{% attendease_content %}
              eos

              File.open("#{site.config['source']}/attendease_layouts/#{layout}.html", 'w+') { |file| file.write(theme_layout_content) }

            end
          end
        end
      end
    end


    class TestPages < Generator
      safe true

      def generate(site)
        if attendease_config = site.config['attendease']

          if attendease_config['test_mode']
            puts "                    [Attendease] Generating pages to test the layouts..."

            puts "                    [Attendease] Generating /register/index.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('register'), {:name => 'index.html', :liquid_tag => 'attendease_test_register_choose_pass'})

            puts "                    [Attendease] Generating /register/checkout.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('register'), {:name => 'checkout.html', :liquid_tag => 'attendease_test_register_checkout'})

            puts "                    [Attendease] Generating /register/dashboard.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('register'), {:name => 'dashboard.html', :liquid_tag => 'attendease_test_register_dashboard'})

            puts "                    [Attendease] Generating /presenters/index.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('presenters'), {:name => 'index.html', :liquid_tag => 'attendease_test_presenters'})

            puts "                    [Attendease] Generating /presenters/presenter.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('presenters'), {:name => 'presenter.html', :liquid_tag => 'attendease_test_presenter'})

            puts "                    [Attendease] Generating /schedule/index.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('schedule'), {:name => 'index.html', :liquid_tag => 'attendease_test_schedule'})

            puts "                    [Attendease] Generating /schedule/session.html"
            site.pages << RegisterTestPage.new(site, site.source, File.join('schedule'), {:name => 'session.html', :liquid_tag => 'attendease_test_session'})
          end

        end
      end
    end

    class RegisterTestPage < Page
      def initialize(site, base, dir, page_data)
        @site = site
        @base = base
        @dir = dir
        @name = page_data[:name]

        self.process(@name)

        if File.exists?(File.join(base, 'attendease_layouts', 'register.html'))
          self.read_yaml(File.join(base, 'attendease_layouts'), 'register.html')
        else
          self.read_yaml(File.join(base, 'attendease_layouts'), 'layout.html')
        end

        self.content.gsub! /\{\% attendease_content \%\}/, "{% #{page_data[:liquid_tag]} %}"
      end
    end


    class AttendeaseTest < Liquid::Tag
      def initialize(tag_name, text, tokens)
        super
        @tag_name = tag_name
      end

      def render(context)
        attendease_data_path = "#{context['site']['source']}/_attendease_data"

        if File.exists?("#{attendease_data_path}/#{@tag_name}.html")
          File.read("#{attendease_data_path}/#{@tag_name}.html")
        else
          raise "Please set the Attendease event data in your _config.yml or read documentation about how to use this tag."
        end
      end
    end


    class AttendeaseContent < Liquid::Tag
      def render(context)
        "{{ content }}"
      end
    end

  end
end

Liquid::Template.register_tag('attendease_content', Jekyll::Attendease::AttendeaseContent)
Liquid::Template.register_tag('attendease_test_register_choose_pass', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_register_checkout', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_register_dashboard', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_schedule', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_session', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_presenters', Jekyll::Attendease::AttendeaseTest)
Liquid::Template.register_tag('attendease_test_presenter', Jekyll::Attendease::AttendeaseTest)
