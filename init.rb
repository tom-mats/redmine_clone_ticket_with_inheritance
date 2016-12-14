Redmine::Plugin.register :redmine_clone_ticket_with_inheritance do
  name 'Redmine Clone Ticket With Inheritance plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

Dir[File.expand_path('../lib/redmine_clone_ticket_with_inheritance', __FILE__) << '/*.rb'].each do |file|
  puts file
  require_dependency file
end

Rails.configuration.to_prepare do
  require_dependency 'projects_helper'
  unless ProjectsHelper.included_modules.include? CloneTicketProjectsHelperPatch
    ProjectsHelper.send(:include, CloneTicketProjectsHelperPatch)
  end
end
