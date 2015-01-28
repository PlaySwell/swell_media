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

			twitter_card = 'summary'
			twitter_card = ENV['TWITTER_WITH_AVATAR_CARD'] || 'summary_large_image' unless @media.try(:avatar).blank?

			if @media.slug == 'homepage'
				set_page_meta( title: "#{ENV['APP_NAME']}", twitter: { site: ENV['TWITTER_SITE'], card: twitter_card, description: ENV['TWITTER_HOMEPAGE_DESCRIPTION'] }, og: { type: 'website', image: @media.avatar, description: ENV['TWITTER_HOMEPAGE_DESCRIPTION'] } )
			elsif @media.title.present?
				set_page_meta( title: "#{@media.title} | #{ENV['APP_NAME']}", description: ActionView::Base.full_sanitizer.sanitize(@media.description), twitter: { site: ENV['TWITTER_SITE'], card: twitter_card }, og: { description: @media.subtitle, image: @media.avatar } )
			else
				set_page_meta( title: "#{@media.sanitized_content[0..128]} | #{ENV['APP_NAME']}", description: ActionView::Base.full_sanitizer.sanitize(@media.content), twitter: { site: ENV['TWITTER_SITE'], card: 'summary' }, og: { description: ActionView::Base.full_sanitizer.sanitize(@media.content), image: @media.avatar } )
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
							if request.path != @media.path
								redirect_to @media.url, status: :moved_permanently and return
							end
						rescue ActiveRecord::RecordNotFound
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					@media = Page.homepage
				end
			end

	end
end