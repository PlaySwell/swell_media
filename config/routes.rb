SwellMedia::Engine.routes.draw do
	root to: 'media#show' # set media to HP if null id

	concern :admin do
		get 	:admin, 	on: :collection
		get		:adminit,	on: :member
	end

	resources :admin, only: :index

	resources :articles, path: 'blog', concerns: :admin do
		get :preview, on: :member
	end

	resources :pages, concerns: :admin do
		get :preview, on: :member
	end


	# devise_scope :user do
	# 	get '/login' => 'sessions#new', as: 'login'
	# 	get '/logout' => 'sessions#destroy', as: 'logout'
	# end
	# devise_for :users, :controllers => { :sessions => 'sessions' }


	# quick catch-all route for static pages
	# set root route to field any media
	get '/:id', to: 'media#show', as: 'media_root'

end
