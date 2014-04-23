module SwellMedia
	class RootController < SwellMedia::MediaController
		before_filter :get_media

		def show
			set_page_info title: @media.title, description: @media.description

			@tags = @media.class.active.tag_counts

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"

			render "#{@media.class.name.underscore.pluralize}/show", layout: layout

		end

		private

			def get_media
				if params[:id].present?
					if params[:id].match( /sitemap/i )
						redirect_to "https://s3-us-west-2.amazonaws.com/#{ENV['FOG_DIRECTORY']}/sitemaps/sitemap.xml.gz"
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

	end
end