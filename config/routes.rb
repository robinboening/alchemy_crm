AlchemyCrm::Engine.routes.draw do

  match '/recipients/:h/reads' => 'recipients#reads',
    :as => 'recipient_reads'

  match '/recipients/:h/reacts' => 'recipients#reacts',
    :as => 'recipient_reacts'

  match '/subscriptions/:token/destroy/:newsletter_id' => 'subscriptions#destroy',
    :as => 'destroy_subscription'

  match '/admin/elements/teasables' => 'admin/elements#teasables',
    :as => 'teasable_elements'

  match '/admin/elements/teasables' => 'admin/elements#teasables',
    :as => 'teasable_elements'

  match '/contacts/:token/verify' => 'contacts#verify',
    :as => 'verify_contact'

  match '/contacts/:token/disable' => 'contacts#disable',
    :as => 'disable_contact'

  match '/mailings/:m/show/:r' => 'mailings#show',
    :as => 'show_mailing'

  resources :mailings, :only => [:show]

  resources :contacts do
    collection do
      post :signup, :signout
    end
  end

  resources :subscriptions do
    collection do
      post :overview
    end
  end

  namespace :admin do

    resources :contacts do
      collection do
        get :import
        get :export
        get :autocomplete_tag_list
        post :mass_create
      end
      member { get :export }
    end

    resources :contact_groups do
      collection { get :add_filter }
    end

    resources :tags, :newsletters

    resources :deliveries

    resources :mailings do
      resources :deliveries
      collection { get :signout }
      member do
        get :copy
        get :edit_content
      end
    end

  end

end
