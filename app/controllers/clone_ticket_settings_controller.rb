class CloneTicketSettingsController < ApplicationController
  unloadable

  before_filter :find_project
  def update
    clone_ticket_settings = CloneTicketSettings.find_or_create(@project.id)
    clone_ticket_settings.assign_attributes(params[:setting])
    clone_ticket_settings.save!
    redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'clone_ticket'
  end

  private
  def find_project
    @project = Project.find(params[:id])
  end
end
