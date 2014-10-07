 module SwellMedia
	class ArticlesController < SwellMedia::MediaController
		before_filter :authenticate_user!, except: [ :index, :show ]
		before_filter :get_article, except: [ :admin, :create, :index ]

		def admin
			authorize( Article )
			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@articles = Article.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@articles = eval "@articles.#{params[:status]}"
			end

			if params[:q].present?
				@articles = @articles.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@articles = @articles.page( params[:page] )

			render layout: 'admin'
		end

		def create
			authorize( Article )
			@article = Article.new( article_params )
			@article.publish_at ||= Time.zone.now
			@article.user = current_user
			@article.status = 'draft'

			if name = params[:article][:category_name]
				@article.category = SwellMedia::Category.where( name: name ).first_or_create( status: 'active' ) unless name.blank?
			end

			if @article.save
				record_user_event( 'publish', user: current_user, on: @article, content: "published <a href='#{@article.url}'>#{@article.to_s}</a>" ) if defined?( SwellPlay )
				set_flash 'Article Created'
				redirect_to edit_article_path( @article )
			else
				set_flash 'Article could not be created', :error, @article
				redirect_to :back
			end
		end

		def destroy
			authorize( Article )
			@article.trash!
			set_flash 'Article Deleted'
			redirect_to :back
		end

		def edit
			authorize( @article )

			render layout: 'admin'
		end

		def index
			@articles = Article.published.order( publish_at: :desc )
			@tags = Article.published.tag_counts

			if @tagged = params[:tagged]
				@articles = @articles.tagged_with( @tagged )
			end

			if @keyword = params[:keyword]
				@articles = @articles.where( "array[:term] && keywords", term: @keyword )
			end

			if params[:by].present? && @author = User.friendly.find( params[:by] )
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

			set_page_meta title: "#{ENV['APP_NAME']} Blog", og: { type: 'blog' }

		end


		def update
			authorize( @article )
			
			@article.slug = nil if params[:article][:slug_pref].present? || params[:article][:title] != @article.title
			@article.attributes = article_params

			if name = params[:article][:category_name]
				@article.category = SwellMedia::Category.where( name: name ).first_or_create( status: 'active' ) unless name.blank?
			end

			if @article.save
				set_flash 'Article Updated'
				redirect_to edit_article_path( id: @article.id )
			else
				set_flash 'Article could not be Updated', :error, @article
				render :edit
			end
			
		end


		private
			def article_params
				params.require( :article ).permit( :title, :subtitle, :slug_pref, :description, :content, :category_id, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar )
			end

			def get_article
				@article = Article.friendly.find( params[:id] )
			end

	end
end