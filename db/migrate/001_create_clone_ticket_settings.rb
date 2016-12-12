class CreateCloneTicketSettings < ActiveRecord::Migration
  def change
    create_table :clone_ticket_settings do |t|
      t.integer :project_id
      t.integer :src_tracker_id
      t.integer :dst_project_id
      t.integer :dst_tracker_id
      t.boolean :copy_attachment
      t.integer :copy_children
      t.integer :copy_related
      t.boolean :back_to_status
    end
  end
end
