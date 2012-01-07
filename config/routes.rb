Logoresize::Application.routes.draw do
  #get "logoresize/index"
  root :to => 'logoresize#index'
  match ':controller(/:action(/:id(.:format)))'
end
