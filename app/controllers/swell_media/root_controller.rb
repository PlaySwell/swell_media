module SwellMedia
	class RootController < SwellMedia::MediaController
		before_filter :get_media

		def show
			
			@tags = @media.class.active.tag_counts

			@media_comments = SwellSocial::UserPost.active.where( parent_obj_id: @media.id, parent_obj_type: @media.class.name ) if defined?( SwellSocial )

			record_user_event( 'impression', user: current_user, on: @media, content: "landed on <a href='#{@media.url}'>#{@media.to_s}</a>" ) if defined?( SwellPlay )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"

			set_page_info title: @media.title, description: @media.description
			
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
						rescue
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					@media = Page.homepage
				end

			end

	end
end