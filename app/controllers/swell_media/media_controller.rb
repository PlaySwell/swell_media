module SwellMedia
	class MediaController < ApplicationController
		before_filter :authenticate_user!, except: [  :index, :random, :show ]
		before_filter :get_media, only: [ :show ]

		
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
			render "#{@media.class.name.underscore.pluralize}/show"
		end


		def random
			@media = Media.active.order( 'random()' ).last
			redirect_to @media.url
		end


		def show
			set_page_info title: @media.title, description: @media.description

			@tags = @media.class.active.tag_counts

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "swell_media#{@media.class.name.underscore.pluralize}"

			render "#{@media.class.name.underscore.pluralize}/show", layout: layout

		end


		def update
			authorize!( :admin, Media )
		end



		private

			def get_media
				if params[:id].present?
					if params[:id].match( /sitemap/i )
						redirect_to "https://s3-us-west-2.amazonaws.com/todo_app_name/com/sitemaps/sitemap.xml.gz"
						return false
					else
						begin
							@media = Media.active.friendly.find( params[:id] )
						rescue
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					@media = Page.homepage
				end

			end

			def media_params
				params.require( :media ).permit( :title, :subtitle, :path, :content, :status, :publish_at, :show_title )
			end
		end
end