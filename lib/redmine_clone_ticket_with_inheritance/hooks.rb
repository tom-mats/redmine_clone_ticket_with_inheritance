module CloneTicketIssuesHooks
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context={})
      copy_issue(context[:issue])
    end
    def controller_issues_bulk_edit_before_save(context={})
      copy_issue(context[:issue])
    end

    private
    def copy_issue(org)
      @settings = CloneTicketSettings.find_or_create(org.project_id)
      return unless @settings
      copied = Issue.new.copy_from(org, {:attachment => @settings[:copy_attachment]})
      copied.project_id = @settings.dst_project_id if @settings.dst_project_id
      copied.tracker_id = @settings.dst_tracker_id if @settings.dst_tracker_id
      copied.custom_field_values = org.custom_field_values.inject({}){ |h,v| h[v.custom_field_id] = v.value; h}
      if @settings.back_to_status
        org_before = Issue.find(org_issue.id)
        org.status_id = org_before.status_id if org_old_issue
      end
      if @settings.clear_related
        org_issue.relations_from.clear
        org_issue.relations_to.clear
      end
      copied.save!
    end
  end
end
