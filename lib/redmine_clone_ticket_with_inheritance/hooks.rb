module CloneTicketIssuesHooks
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context={})
      new_issue = copy_from(context[:issue])
    end
    def controller_issues_bulk_edit_before_save(context={})
      new_issue = copy_from(context[:issue])
    end

    private
    def copy_ticket(org_issue)
      new_issue = Issue.copy_from(org_issue)
      new_issue
    end
  end
end
