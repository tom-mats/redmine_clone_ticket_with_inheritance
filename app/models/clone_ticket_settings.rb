class CloneTicketSettings < ActiveRecord::Base
  unloadable

  belongs_to :project

  attr_accessible :project_id, :dst_project_id, :dst_tracker_id, :copy_attachment, :copy_children, :copy_related, :back_to_status, :force_category

  def self.find_or_create(project_id)
    own_setting = CloneTicketSettings.find_by(project_id: project_id)
    unless own_setting
      own_setting = CloneTicketSettings.new
      own_setting.project_id = project_id
      own_setting.save!
    end
    own_setting
  end
end
