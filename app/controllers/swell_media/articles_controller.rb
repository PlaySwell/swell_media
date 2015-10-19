 module SwellMedia
	class ArticlesController < ApplicationController
		
		def index
			@articles = Article.published.order( publish_at: :desc )
			@tags = []# Article.published.tags_counts

			if @tagged = params[:tagged]
				@articles = @articles.with_any_tags( @tagged )
			end

			if @keyword = params[:keyword]
				@articles = @articles.where( "array[:term] && keywords", term: @keyword )
			end

			if params[:by].present? && @author = SwellMedia.registered_user_class.constantize.friendly.find( params[:by] )
				@articles = @articles.where( user_id: @author.id )
			end

			cat = params[:category] || params[:cat]

			if cat.present? && @category = Category.friendly.find( cat )		
				@articles = @articles.where( category_id: @category.id )
			end

			if params[:q].present?
				@query = params[:q]
				@articles = @articles.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: "#{SwellMedia.app_name} Blog", og: { type: 'blog' }, twitter: { card: 'summary' }

			record_user_event( event: 'page_view', content: "landed on <a href='#{request.url}'>#{controller_name}##{action_name}</a>" )
			
		end


	end
end