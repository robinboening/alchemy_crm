ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :tags, :contact_groups, :newsletters
    admin.resources :sent_mailings, :member => {:pdf => :get}
    admin.resources :mailings, :member => {:copy => :post, :deliver => [:get, :post]}, :collection => {:signout => :get}, :has_many => :sent_mailings, :shallow => true
    admin.resources :contacts, :collection => {:import => :get}, :member => {:export => :get}
  end
  map.resources :mailings, :collection => {:signout => :get}
  map.resources :contacts, :collection => {:signup => :get, :signout => :get, :verify => :get}
  map.verify_mailing 'contacts/verify/:sha1', :controller => 'contacts', :action => 'verify'
end
