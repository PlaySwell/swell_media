SwellMedia::Engine.routes.draw do
	root to: 'root#show' # set media to HP if null id

	concern :admin do
		get 	:admin, 	on: :collection
		get		:adminit,	on: :member
	end

	resources :admin, only: :index

	resources :articles, path: 'blog', concerns: :admin do
		get :preview, on: :member
	end

	resources :categories, concerns: :admin

	resources :contacts, concerns: :admin

	resources :optins, only: :create

	resources :pages, concerns: :admin do
		get :preview, on: :member
	end

	resources :imports
	resources :exports

	# quick catch-all route for static pages
	# set root route to field any media
	get '/:id', to: 'root#show', as: 'root_show'

end
