# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
  match 'projects/:id/clone_ticket_settings/:action', :controller => 'clone_ticket_settings', :via => [:get, :post, :put, :patch] 
end
