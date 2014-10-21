module SwellMedia
	class RootController < SwellMedia::MediaController
		before_filter :get_media

		def show
			
			@tags = @media.class.active.tag_counts

			if defined?( SwellSocial )
				@media_comments = SwellSocial::UserPost.active.where( parent_obj_id: @media.id, parent_obj_type: @media.class.name )

				@media_comments = @media_comments.tagged_with(params[:comment_tag]) if params[:comment_tag]
			end

			record_user_event( 'impression', user: current_user, on: @media, rate: 23.hours, content: "landed on <a href='#{@media.url}'>#{@media.to_s}</a>" ) if defined?( SwellPlay )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"

			if @media.slug == 'homepage'
				set_page_meta( title: "#{ENV['APP_NAME']}", og: { type: 'website', image: @media.avatar } )
			elsif @media.title.present?
				set_page_meta( title: "#{@media.title} | #{ENV['APP_NAME']}", description: ActionView::Base.full_sanitizer.sanitize(@media.description), og: { description: @media.subtitle, image: @media.avatar } )
			else
				set_page_meta( title: "#{@media.sanitized_content[0..128]} | #{ENV['APP_NAME']}", description: @media.content, og: { description: ActionView::Base.full_sanitizer.sanitize(@media.content), image: @media.avatar } )
			end

			begin
				render "#{@media.class.name.underscore.pluralize}/show", layout: layout
			rescue ActionView::MissingTemplate
				render "#{@media.class.name.underscore.pluralize}/show", layout: 'application'
			end

		end

		private

			def get_media
				if params[:id].present?
					if params[:id].match( /sitemap/i )
						redirect_to "https://s3-us-west-2.amazonaws.com/#{ENV['FOG_DIRECTORY']}/sitemaps/sitemap.xml.gz"
						return false
					else
						begin

							@media = Media.published.friendly.find( params[:id] )
						rescue => e
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					@media = Page.homepage
				end

			end

	end
end