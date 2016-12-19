class CloneTicketSettings < ActiveRecord::Base
  unloadable

  belongs_to :project

  #safe_attributes 'dst_project_id', 'dst_tracker_id', 'copy_attachment', 'copy_children', 'copy_related', 'back_to_status'
  attr_accessible :project_id, :dst_project_id, :dst_tracker_id, :copy_attachment, :copy_children, :copy_related, :back_to_status

  def self.find_or_create(project_id)
    p Tracker.all.sort
    own_setting = CloneTicketSettings.find_by(project_id: project_id)
    unless own_setting
      own_setting = CloneTicketSettings.new
      own_setting.project_id = project_id
      own_setting.save!
    end
    own_setting
  end
end
