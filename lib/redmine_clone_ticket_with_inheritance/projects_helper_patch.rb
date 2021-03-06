require_dependency 'projects_helper'

module CloneTicketProjectsHelperPatch
  def self.included(base)
    base.send(:include, ProjectsHelperMethodCloneTicket)
    base.class_eval do
      alias_method_chain :project_settings_tabs, :clone_ticket
    end
  end

  module ProjectsHelperMethodCloneTicket
    def project_settings_tabs_with_clone_ticket
      tabs = project_settings_tabs_without_clone_ticket # call super
      if @project.module_enabled?(:clone_ticket_with_inheritance)
        @clone_ticket_settings = CloneTicketSettings.find_or_create(@project.id)
        action =
          {
            name: 'clone_ticket',
            controller: 'clone_ticket_settings',
            action: :edit,
            partial: 'clone_ticket_settings/show',
            label: :clone_ticket
          }
        tabs << action
      end
      tabs
    end
  end
end
