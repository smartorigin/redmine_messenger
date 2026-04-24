# frozen_string_literal: true

loader = RedminePluginKit::Loader.new plugin_id: 'redmine_messenger'

Redmine::Plugin.register :redmine_messenger do
  name 'Messenger'
  author 'Smart/Origin'
  url 'https://github.com/smartorigin/redmine_messenger'
  author_url 'https://smart-origin.com/'
  description 'Messenger integration for Slack, Discord, Rocketchat and Mattermost support'
  version RedmineMessenger::VERSION

  requires_redmine version_or_higher: '4.2.0'

  permission :manage_messenger, projects: :settings, messenger_settings: :update

  settings default: loader.default_settings, partial: 'settings/messenger_settings'
end

RedminePluginKit::Loader.persisting { loader.load_model_hooks! }
RedminePluginKit::Loader.to_prepare { RedmineMessenger.setup! } if Rails.version < '6.0'
