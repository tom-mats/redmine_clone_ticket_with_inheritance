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

    def category_id_with_force(name)
      params = {:project_id => @clone_with.dst_project_id, :name => name}
      new_category = IssueCategory.find_by(params) || IssueCategory.new(params)
      new_category.save! if new_category.id.nil?
      new_category.id
    end

    def category_id(org)
      return if !(@clone_with.force_category) || org.category_id.nil?
      org_category = IssueCategory.find_by_id(org.category_id)
      category_id_with_force(org_category.name)
    end

    def fixed_version_id_by_custom_fields
      return unless @clone_with.use_cf_as_version
      v = @dst_project.shared_versions.select{|e| IssueCustomField.find_by_default_value(e.name).present?}
      v.first.id if v.present?
    end

    def fixed_version_id(org)
      if org.fixed_version_id && @dst_project.shared_versions.select{|e| e.id == org.fixed_version_id}.present?
        org.fixed_version_id
      else
        fixed_version_id_by_custom_fields
      end
    end

    def clear_relation(copied, org)
      org.relations_from.clear
      new_rel = IssueRelation.new(:issue_from => org, :issue_to => copied, :relation_type => IssueRelation::TYPE_COPIED_TO)
      new_rel.save!
    end

    def create_relation(copied, issue)
      return if issue.nil? || issue.id == copied.id
      params = {:issue_from => copied, :issue_to => issue, :relation_type => IssueRelation::TYPE_FOLLOWS}
      new_rel = IssueRelation.new(params)
      new_rel.save!
    end

    def move_or_copy_relation(org, copied)
      copy_history = org.relations_from.select {|e| e.relation_type == IssueRelation::TYPE_COPIED_TO}
      clear_relation(copied, org) if @clone_with.clear_related
      copy_history.each { |rel|  create_relation(copied, Issue.find(rel.issue_to_id)) }
    end

    def link_to_result(copied)
      "##{copied.id}"
    end

    def target_cf(org, name)
      target = IssueCustomField.find_by_name(name)
      org.custom_field_values.select { |cf| cf.custom_field.id == target.id }.first
    end

    def add_link_to_results(copied, org)
      cf = target_cf(org, 'Latest result')
      cf.value = link_to_result(copied) if cf.present?

      cf = target_cf(org, 'Results')
      cf.value = cf.value.split(',').unshift(link_to_result(copied)).first(10).join(',') if cf.present?
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
      copied.fixed_version_id = fixed_version_id(org)
      copied.custom_field_values = org.custom_field_values.inject({}){ |h,v| h[v.custom_field_id] = v.value; h}
      copied.save!

      back_to_origin(org_before, org)
      move_or_copy_relation(org, copied)
      add_link_to_results(copied, org)
    end
  end
end
