AlchemyCrm::Engine.routes.draw do

	match '/recipients/reads/:id' => 'recipients#reads',
		:as => 'recipient_reads'
	
	match '/recipients/reacts/:id' => 'recipients#reacts',
		:as => 'recipient_reacts'
	
	match '/subscriptions/destroy/:newsletter_id/:token/:element_id' => 'subscriptions#destroy',
		:as => 'destroy_subscription'
	
	match '/admin/elements/teasables' => 'admin/elements#teasables',
		:as => 'teasable_elements'
	
	match '/admin/elements/teasables' => 'admin/elements#teasables',
		:as => 'teasable_elements'

	match '/contacts/:token/verify/:element_id' => 'contacts#verify',
		:as => 'verify_contact'

	match '/subscriptions/:id/verify/:element_id' => 'contacts#verify',
		:as => 'verify_subscription'

	resources :mailings, :only => :show

	resources :contacts do
		collection do
			post :signup
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
				get :autocomplete_tag_list
				post :import
			end
			member { get :export }
		end

		resources :contact_groups do
			collection { get :add_filter }
		end

		resources :tags, :newsletters

		resources :deliveries do
			member { get :pdf }
		end

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
