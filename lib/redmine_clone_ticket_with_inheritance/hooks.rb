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
      @project = Project.find(org.project_id)
      return unless @project.module_enabled?(:clone_ticket_with_inheritance)

      @clone_with = CloneTicketSettings.find_or_create(@project.id)
      return unless @clone_with
      org_before = Issue.find(org.id)
      return if org_before.status_id == org.status_id

      copied = Issue.new.copy_from(org, {:attachment => @clone_with[:copy_attachment]})
      copied.project_id = @clone_with.dst_project_id if @clone_with.dst_project_id
      copied.tracker_id = @clone_with.dst_tracker_id if @clone_with.dst_tracker_id
      if @clone_with.force_category && org.category_id
        org_category = IssueCategory.find_by_id(org.category_id)
        params = {:project_id => @clone_with.dst_project_id, :name => org_category.name}
        new_category = IssueCategory.find_by(params)
        unless new_category
          new_category = IssueCategory.new(params)
          new_category.save!
        end
        copied.category_id = new_category.id
      end
      copied.custom_field_values = org.custom_field_values.inject({}){ |h,v| h[v.custom_field_id] = v.value; h}
      if @clone_with.back_to_status
        org.status_id = org_before.status_id if org_before
      end
      if @clone_with.clear_related
        org_issue.relations_from.clear
        org_issue.relations_to.clear
      end
      copied.save!
    end
  end
end
