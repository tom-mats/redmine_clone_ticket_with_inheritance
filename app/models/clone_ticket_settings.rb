class CloneTicketSettings < ActiveRecord::Base
  unloadable

  belongs_to :project
  validates_uniqueness_of :project_id
  validates_presence_of :project_id

  safe_attributes 'dst_project_id', 'dst_tracker_id', 'copy_attachment', 'copy_children', 'copy_related', 'back_to_status'
  attr_accessible :dst_project_id, :dst_tracker_id, :copy_attachment, :copy_children, :copy_related, :back_to_status

  def find_or_create(project_id)
    own_setting = CloneTicketSettings.where(project_id: project_id).first
    unless own_setting.present?
      own_setting = CloneTicketSettings.new
      own_setting.project_id = project_id
      own_setting.save!
    end
    own_setting
  end
end
