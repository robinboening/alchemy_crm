ActionController::Routing::Routes.draw do |map|
  map.resources :mailings, :collection => {:signout => :get}
  map.resources :contacts, :collection => {:signup => :get, :signout => :get, :verify => :get}
  map.verify_mailing 'contacts/verify/:sha1', :controller => 'contacts', :action => 'verify'
  map.namespace :admin do |admin|
    admin.resources :contacts, :collection => {:import => :get}, :member => {:export => :get}
    admin.resources :contact_groups, :member => {:add_filter => :get}
    admin.resources :tags, :newsletters
    admin.resources :sent_mailings, :member => {:pdf => :get}
    admin.resources :mailings, :member => {:copy => :post, :deliver => [:get, :post]}, :collection => {:signout => :get}, :has_many => :sent_mailings, :shallow => true
  end
end
