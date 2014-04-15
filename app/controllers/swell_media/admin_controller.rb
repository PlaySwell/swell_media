module SwellMedia

	class AdminController < ApplicationController
		before_filter :authenticate_user!
		
		def index
			authorize!( :admin, Media )
			@articles = Article.order( publish_at: :desc ).limit( 10 )
			@pages = Page.order( publish_at: :desc ).limit( 10 )
			render layout: 'gkadmin'
		end
	end

end