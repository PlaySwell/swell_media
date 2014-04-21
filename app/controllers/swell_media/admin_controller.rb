module SwellMedia

	class AdminController < ApplicationController
		before_filter :authenticate_user!
		
		def index
			df
			authorize!( :admin, Media )
			@articles = Article.order( publish_at: :desc ).limit( 10 )
			@pages = Page.order( publish_at: :desc ).limit( 10 )
			@contacts = Contact.order( created_at: :desc ).limit( 10 )
			render layout: 'admin'
		end
	end

end