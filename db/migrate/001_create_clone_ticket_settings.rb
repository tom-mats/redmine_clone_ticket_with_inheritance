class CreateCloneTicketSettings < ActiveRecord::Migration
  def change
    create_table :clone_ticket_settings do |t|
      t.belongs_to :project, index: true, foreign_key: true
      t.integer :project_id
      t.integer :src_tracker_id
      t.integer :dst_project_id
      t.integer :dst_tracker_id
      t.boolean :copy_attachment
      t.boolean :copy_children
      t.boolean :clear_related
      t.boolean :back_to_status
      t.boolean :force_category
    end
  end
end
