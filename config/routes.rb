SwellMedia::Engine.routes.draw do
	root to: 'root#show' # set media to HP if null id

	resources :admin, only: :index

	resources :articles, path: 'blog'
	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection 
	end

	resources :categories
	resources :category_admin

	resources :contacts
	resources :contact_admin

	resources :pages
	resources :page_admin do
		get :preview, on: :member
	end

	resources :assets do
		post :callback_create, on: :collection
		get :callback_create, on: :collection
	end

	resources :imports
	resources :exports

	# quick catch-all route for static pages
	# set root route to field any media
	get '/:id', to: 'root#show', as: 'root_show'

end
