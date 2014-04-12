module SwellMedia
	class ArticlesController < MediaController
		before_filter :authenticate_user!, except: [ :index, :show ]
		before_filter :get_article, except: [ :admin, :create, :index ]

		def admin
			authorize!( :admin, Article )
			@articles = Article.order( publish_at: :desc ).page( params[:page] )
			render layout: 'swell_media/admin'
		end

		def create
			authorize!( :admin, Article )
			@article = Article.new( article_params )
			@article.publish_at ||= Time.zone.now
			@article.user = current_user
			@article.status = 'draft'
			if @article.save
				set_flash 'Article Created'
				redirect_to edit_article_path( @article )
			else
				set_flash 'Article could not be created', :error, @article
				redirect_to :back
			end
		end

		def destroy
			authorize!( :admin, Article )
			@article.update( status: 'deleted' )
			set_flash 'Article Deleted'
			redirect_to :back
		end

		def edit
			authorize!( :admin, Article )

			render layout: 'swell_media/admin'
		end

		def index
			@articles = Article.active.order( publish_at: :desc )
			@tags = Article.active.tag_counts

			if @tagged = params[:tagged]
				@articles = @articles.tagged_with( @tagged )
			end

			if @keyword = params[:keyword]
				@articles = @articles.where( "array[:term] && keywords", term: @keyword )
			end

			if params[:by].present? && @author = User.friendly.find( params[:by] )
				@articles = @articles.where( user_id: @author.id )
			end

			if params[:category].present? && @category = Category.friendly.find( params[:category] )		
				@articles = @articles.where( category_id: @category.id )
			end

			if params[:q].present?
				@query = params[:q]
				@articles = @articles.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@articles = @articles.page( params[:page] )

		end

		def update
			authorize!( :admin, Article )
			
			@article.slug = nil if params[:article][:path].present? || params[:article][:title] != @article.title
			@article.attributes = article_params

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
				params.require( :article ).permit( :title, :subtitle, :path, :description, :content, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar )
			end

			def get_article
				@article = Article.friendly.find( params[:id] )
			end

	end
end