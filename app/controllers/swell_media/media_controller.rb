module SwellMedia
	class MediaController < ApplicationController
		# only used for global admin (any media) and preview.
		# media#show should route to root controller for naked paths (e.g. domain/slug )
		# or to the controller of choice for scoped paths (e.g. domain/blog/id to articles#show )

		before_filter :authenticate_user!, except: [  :index, :random, :show ]

		def admin
			authorize!( :admin, Media )
			@media = Media.order( publish_at: :desc )
			render layout: 'admin'
		end


		def create
			authorize!( :admin, Media )
			# TODO - move internal admin media creation here....
			# move community media adding to above add method
			@media = params[:media][:type].constantize.new( media_params )
			@media.user_id = current_user.id
			@media.status = 'draft'
			@media.publish_at ||= Time.zone.now
			if @media.save
				set_flash "#{@media.class.name} Created"
			else
				set_flash "#{@media.class.name} could not be created", :error, @media
			end
			redirect_to :back
		end


		def destroy
			authorize!( :admin, Media )
			@media.update( status: 'deleted' )
			set_flash 'Media Deleted'
			redirect_to :back
		end


		def preview
			authorize!( :admin, Media )
			@media = Media.friendly.find( params[:id] )
			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"
			render "#{@media.class.name.underscore.pluralize}/show"
		end


		private

			def media_params
				params.require( :media ).permit( :title, :subtitle, :path, :content, :status, :publish_at, :show_title )
			end
		end
end