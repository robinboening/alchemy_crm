ActionController::Routing::Routes.draw do |map|
  map.recipient_reads 'recipients/reads/:id', :controller => :recipients, :action => :reads
  map.recipient_reacts 'recipients/reacts/:id', :controller => :recipients, :action => :reacts
  map.resources :mailings, :collection => {:signout => :get}
  map.resources :contacts, :collection => {:signup => :post, :signout => :get, :verify => :get}, :except => [:index, :show, :new, :create, :edit, :update, :destroy]
  map.verify_mailing 'contacts/verify/:sha1/:element_id', :controller => 'contacts', :action => 'verify'
  map.teasable_elements '/admin/elements/teasables', :controller => 'admin/elements', :action => :teasables
  map.resources :newsletter_subscriptions
  map.namespace :admin do |admin|
    admin.resources :contacts, :collection => {:import => :get}, :member => {:export => :get}
    admin.resources :contact_groups, :collection => {:add_filter => :get}
    admin.resources :tags, :newsletters
    admin.resources :sent_mailings, :member => {:pdf => :get}
    admin.resources :mailings, :member => {:copy => :get, :deliver => [:get, :post]}, :collection => {:signout => :get}, :has_many => :sent_mailings, :shallow => true
  end
end
