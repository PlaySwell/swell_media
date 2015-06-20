module SwellMedia
	class RootController < ApplicationController
		before_filter :get_media

		def show
			
			@tags = @media.class.active.tag_counts

			if defined?( SwellSocial )
				@media_comments = SwellSocial::UserPost.active.where( parent_obj_id: @media.id, parent_obj_type: @media.class.name )
				@media_comments = @media_comments.tagged_with( params[:comment_tag] ) if params[:comment_tag].present?
			end

			if @media.user_id.present?
				@guest_session.update( content_user_id: @media.user_id )
			end
			
			record_user_event( 'impression', on: @media, rate: 23.hours, content: "landed on <a href='#{@media.url}'>#{@media.to_s}</a>" )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"

			layout = @media.layout if @media.layout.present?

			set_page_meta( @media.page_meta )

			begin
				begin
					render "#{@media.class.name.underscore.pluralize}/show+#{@guest_session.device_format}", layout: layout
				rescue ActionView::MissingTemplate
					render "#{@media.class.name.underscore.pluralize}/show", layout: layout
				end
			rescue ActionView::MissingTemplate
				render "#{@media.class.name.underscore.pluralize}/show", layout: 'application'
			end

		end

		private

			def get_media

				if params[:id].present?
					if params[:id].match( /sitemap/i )
						redirect_to "https://s3.amazonaws.com/#{ENV['FOG_DIRECTORY']}/sitemaps/sitemap.xml.gz"
						return false
					else
						begin
							@media = Media.published.friendly.find( params[:id] )
							# if request.path != @media.path
							# 	redirect_to @media.url, status: :moved_permanently and return
							# end
						rescue ActiveRecord::RecordNotFound
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					redirect_to root_path
					return false
				end
			end

	end
end