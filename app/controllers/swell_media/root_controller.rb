module SwellMedia
	class RootController < ( SwellMedia.root_controller_parent_class || ApplicationController )
		before_filter :get_media

		def show
			@tags = []
			#@tags = @media.class.active.tags_cloud

			if defined?( SwellSocial )
				@media_comments = SwellSocial::UserPost.active.where( parent_obj_id: @media.id, parent_obj_type: @media.class.name ).order( created_at: :desc )
				@media_comments = @media_comments.with_any_tags( params[:comment_tag] ) if params[:comment_tag].present?
			end

			if @media.user.present?
				@guest_session.update( content_src_user: @media.user.try( :slug ) )
			end

			record_user_event( event: 'page_view', on: @media, content: "landed on <a href='#{@media.url}'>#{@media.to_s}</a>" )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"

			layout = @media.layout if @media.layout.present?

			set_page_meta( @media.page_meta )

			self.before_render if self.respond_to? :before_render

			begin
				begin
					render "#{@media.class.name.underscore.pluralize}/show+#{@guest_session.device_format}", layout: layout
				rescue ActionView::MissingTemplate
					render "#{@media.class.name.underscore.pluralize}/show", layout: layout
				end
			rescue ActionView::MissingTemplate
				render "#{@media.class.name.underscore.pluralize}/show", layout: 'application'
			end

			self.after_render if self.respond_to? :after_render

		end

		private

			def get_media

				if params[:id].present?
					if params[:id].match( /sitemap/i )
						redirect_to "https://s3.amazonaws.com/#{ENV['FOG_DIRECTORY']}/sitemaps/sitemap.xml.gz"
						return false
					else
						begin
							@media = Media.friendly.find( params[:id] )
							if @media.try( :redirect_url )
								redirect_to @media.redirect_url, status: :moved_permanently and return
							elsif !@media.published?
								raise ActionController::RoutingError.new( 'Not Found' )
							end
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