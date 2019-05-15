require 'jekyll'
require 'httparty'
require 'json'
require 'i18n'
require 'digest'

require 'jekyll/attendease_plugin'

Liquid::Template.register_tag('attendease_schedule_widget',  Jekyll::AttendeasePlugin::ScheduleWidgetTag)
Liquid::Template.register_tag('attendease_auth_script',      Jekyll::AttendeasePlugin::AuthScriptTag)
Liquid::Template.register_tag('attendease_scheduler_script', Jekyll::AttendeasePlugin::SchedulerScriptTag)
Liquid::Template.register_tag('attendease_locales_script',   Jekyll::AttendeasePlugin::LocalesScriptTag)
Liquid::Template.register_tag('attendease_auth_account',     Jekyll::AttendeasePlugin::AuthAccountTag)
Liquid::Template.register_tag('attendease_auth_action',      Jekyll::AttendeasePlugin::AuthActionTag)
Liquid::Template.register_tag('attendease_t',                Jekyll::AttendeasePlugin::TranslateTag)
Liquid::Template.register_tag('attendease_nav',              Jekyll::AttendeasePlugin::NavigationTag)
Liquid::Template.register_tag('attendease_portal_nav',       Jekyll::AttendeasePlugin::PortalNavigationTag)
Liquid::Template.register_tag('attendease_block_renderer',   Jekyll::AttendeasePlugin::BlockRendererTag)
Liquid::Template.register_tag('attendease_analytics_gtm_head', Jekyll::AttendeasePlugin::AnalyticsGoogleTagManagerHeadTag)
Liquid::Template.register_tag('attendease_analytics_gtm_body', Jekyll::AttendeasePlugin::AnalyticsGoogleTagManagerBodyTag)
Liquid::Template.register_tag('attendease_analytics_ga_gtag',  Jekyll::AttendeasePlugin::AnalyticsGoogleAnalyticsGtagTag)
Liquid::Template.register_tag('attendease_analytics_facebook', Jekyll::AttendeasePlugin::AnalyticsFacebookPixelTag)
Liquid::Template.register_tag('attendease_analytics_linkedin', Jekyll::AttendeasePlugin::AnalyticsLinkedInTag)
Liquid::Template.register_tag('attendease_analytics_settings', Jekyll::AttendeasePlugin::AnalyticsSettingsTag)
Liquid::Template.register_tag('attendease_sentry', Jekyll::AttendeasePlugin::SentryTag)

Liquid::Template.register_filter(Jekyll::AttendeasePlugin::Filters)
