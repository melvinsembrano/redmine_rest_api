require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting Redmine REST Api plugin'

Redmine::Plugin.register :redmine_rest_api do
  name 'Redmine REST Api plugin'
  author 'Allan Melvin T. Sembrano - melvinsembrano@gmail.com'
  description 'Plugin for exposing Redmine RESTful apis'
  version '0.0.1'
end

ActionController::Base.send :include, ApplicationMethods

Attachment.send :include, ModelMethods::Attachment