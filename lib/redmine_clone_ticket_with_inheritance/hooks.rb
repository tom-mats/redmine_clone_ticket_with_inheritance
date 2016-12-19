module CloneTicketIssuesHooks
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context={})

    end
    def controller_issues_bulk_edit_before_save(context={})
      
    end
  end
end
