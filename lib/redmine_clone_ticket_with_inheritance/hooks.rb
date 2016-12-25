module CloneTicketIssuesHooks
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context={})
      copy_issue(context[:issue])
    end
    def controller_issues_bulk_edit_before_save(context={})
      copy_issue(context[:issue])
    end

    private
    def back_to_origin(org, issue)
      issue.status_id = org.status_id if @clone_with.back_to_status
      issue.fixed_version_id = org.fixed_version_id if @clone_with.back_to_version
    end

    def new_category_with_force(name)
      params = {:project_id => @clone_with.dst_project_id, :name => name}
      new_category = IssueCategory.find_by(params)
      unless new_category
        new_category = IssueCategory.new(params)
        new_category.save!
      end
      new_category
    end

    def category_id(org)
      if @clone_with.force_category && org.category_id
        org_category = IssueCategory.find_by_id(org.category_id)
        new_category_with_force(org_category.name).id
      end
    end

    def fixed_version_id_by_custom_fields(cfs)
      if @clone_with.use_cf_as_version
        v = @dst_project.shared_versions.select{|e| cfs.select { |cf| cf.custom_field.default_value == e.name}.present?}
        v.first.id if v.present?
      end
    end

    def fixed_version_id(org, cfs)
      if org.fixed_version_id && @dst_project.shared_versions.select{|e| e.id == org.fixed_version_id}.present?
        org.fixed_version_id
      else
        fixed_version_id_by_custom_fields(cfs)
      end
    end

    def move_or_copy_relation(org, copied)
      copy_history = org.relations_from.select {|e| e.relation_type == IssueRelation::TYPE_COPIED_TO}
      if @clone_with.clear_related
        org.relations_from.clear
        new_rel = IssueRelation.new(:issue_from => org, :issue_to => copied, :relation_type => IssueRelation::TYPE_COPIED_TO)
        new_rel.save!
      end

      params = {:issue_from => copied, :relation_type => IssueRelation::TYPE_FOLLOWS}
      copy_history.each do |rel|
        hist_issue = Issue.find(rel.issue_to_id)
        if hist_issue && hist_issue.id != copied.id
          new_rel = IssueRelation.new(params.merge({:issue_to => hist_issue}))
          new_rel.save!
        end
      end
    end

    def copy_issue(org)
      @project = Project.find(org.project_id)
      return unless @project.module_enabled?(:clone_ticket_with_inheritance)

      @clone_with = CloneTicketSettings.find_or_create(@project.id)
      return if @clone_with.nil?

      org_before = Issue.find(org.id)
      return if org_before.nil? || org_before.status_id == org.status_id

      @dst_project = Project.find(@clone_with.dst_project_id)
      return if @dst_project.nil?

      copied = Issue.new.copy_from(org, {:attachment => @clone_with[:copy_attachment]})
      copied.project_id = @clone_with.dst_project_id if @clone_with.dst_project_id
      copied.tracker_id = @clone_with.dst_tracker_id if @clone_with.dst_tracker_id
      copied.category_id = category_id(org)
      copied.fixed_version_id = fixed_version_id(org, copied.custom_field_values)
      copied.custom_field_values = org.custom_field_values.inject({}){ |h,v| h[v.custom_field_id] = v.value; h}
      copied.save!

      back_to_origin(org_before, org)
      move_or_copy_relation(org, copied)
    end
  end
end
