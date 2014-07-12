require 'jekyll'
require 'httparty'
require 'json'
require 'i18n'

require 'jekyll/attendease_plugin'

Liquid::Template.register_tag('attendease_auth_script', Jekyll::AttendeasePlugin::AuthScriptTag)
Liquid::Template.register_tag('attendease_scheduler_script', Jekyll::AttendeasePlugin::SchedulerScriptTag)
Liquid::Template.register_tag('attendease_locales_script', Jekyll::AttendeasePlugin::LocalesScriptTag)
Liquid::Template.register_tag('attendease_auth_account', Jekyll::AttendeasePlugin::AuthAccountTag)
Liquid::Template.register_tag('attendease_auth_action', Jekyll::AttendeasePlugin::AuthActionTag)
Liquid::Template.register_tag('t', Jekyll::AttendeasePlugin::TranslateTag)

Liquid::Template.register_filter(Jekyll::AttendeasePlugin::Filters)
