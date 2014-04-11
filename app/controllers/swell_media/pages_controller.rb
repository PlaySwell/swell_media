module SwellMedia
	class PagesController < ApplicationController
		
		def admin
			authorize! :admin, SwellMedia::Page
			@media = SwellMedia::Page.where( site_id: @current_site.id ).page( params[:page] )
			render layout: 'admin'
		end

		def edit
			@media = SwellMedia::Page.where( site_id: @current_site.id ).find( params[:id] )
			redirect_to edit_media_path( @media.id )
		end
		
	end
end