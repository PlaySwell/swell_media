module SwellMedia
	class MediaController < ApplicationController
		# only used for global admin (any media) and preview.
		# media#show should route to root controller for naked paths (e.g. domain/slug )
		# or to the controller of choice for scoped paths (e.g. domain/blog/id to articles#show )

		before_filter :authenticate_user!, except: [  :index, :random, :show ]

		def admin
			authorize( Media )
			@media = Media.order( publish_at: :desc )
			render layout: 'admin'
		end


		def preview
			@media = Media.friendly.find( params[:id] )

			authorize( @media )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"
			render "#{@media.class.name.underscore.pluralize}/show"
		end


		private

			def media_params
				params.require( :media ).permit( :title, :subtitle, :path, :content, :status, :publish_at, :show_title )
			end
		end
end