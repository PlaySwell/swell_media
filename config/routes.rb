SwellMedia::Engine.routes.draw do
	root to: 'root#show' # set media to HP if null id

	get 'out/(:type(/:id))' => 'outbound#show', as: :outbound

	resources :admin, only: :index

	resources :articles, path: 'blog'
	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection 
	end

	resources :assets do
		post :callback_create, on: :collection
		get :callback_create, on: :collection
	end

	resources :category_admin

	resources :contacts
	resources :contact_admin

	resources :oauth_email_collector, only: [:create, :new]

	resources :page_admin do
		get :preview, on: :member
		delete :empty_trash, on: :collection 
	end

	resources :stats_admin

	resources :user_events, only: :create
	resources :user_event_admin

	resources :user_admin

	resources :imports
	resources :exports

	#resources :sessions

	devise_scope :user do
		get '/login' => 'sessions#new', as: 'login'
		get '/logout' => 'sessions#destroy', as: 'logout'
	end
	devise_for :users, :controllers => { :omniauth_callbacks => 'swell_media/oauth', :registrations => 'swell_media/registrations', :sessions => 'swell_media/sessions', :passwords => 'swell_media/passwords' }



	# quick catch-all route for static pages
	# set root route to field any media
	get '/:id', to: 'root#show', as: 'root_show'

end
