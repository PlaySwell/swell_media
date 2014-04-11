module SwellMedia

	class AdminController < ApplicationController
		before_filter :authenticate_user!
		

		layout 'swell_media/admin'


		def index
			authorize!( :admin, Media )
			@articles = Article.order( publish_at: :desc ).limit( 10 )
			@pages = Page.order( publish_at: :desc ).limit( 10 )
		end
	end

end