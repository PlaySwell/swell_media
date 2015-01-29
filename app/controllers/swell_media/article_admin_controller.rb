module SwellMedia
	class ArticleAdminController < ApplicationController

		before_filter :authenticate_user!
		before_filter :get_article, except: [ :create, :empty_trash, :index ]

		layout 'admin'


		def create
			authorize( Article, :admin_create? )
			@article = Article.new( article_params )
			@article.publish_at ||= Time.zone.now
			@article.user = current_user
			@article.status = 'draft'

			if params[:article][:category_name].present?
				@article.category = SwellMedia::Category.where( name: params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			if @article.save
				set_flash 'Article Created'
				redirect_to edit_article_admin_path( @article )
			else
				set_flash 'Article could not be created', :error, @article
				redirect_to :back
			end
		end


		def destroy
			authorize( Article, :admin_destroy? )
			@article.trash!
			set_flash 'Article Deleted'
			redirect_to :back
		end


		def edit
			authorize( @article, :admin_edit? )
		end


		def empty_trash
			authorize( Article, :admin_empty_trash? )
			@articles = Article.trash.destroy_all
			redirect_to :back
			set_flash "#{@articles.count} destroyed"
		end


		def index
			authorize( Article, :admin? )
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
		end


		def preview
			authorize( @article, :admin_preview? )
			@media = @article
			layout = 'swell_media/articles' #@media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"
			render "swell_media/articles/show"
		end


		def update
			authorize( @article, :admin_update? )
			
			@article.slug = nil if params[:update_slug].present? && params[:article][:title] != @article.title

			@article.attributes = article_params

			if params[:article][:category_name].present?
				@article.category = SwellMedia::Category.where( params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			if @article.save
				set_flash 'Article Updated'
				redirect_to edit_article_admin_path( id: @article.id )
			else
				set_flash 'Article could not be Updated', :error, @article
				render :edit
			end
			
		end


		private
			def article_params
				params.require( :article ).permit( :title, :subtitle, :slug_pref, :description, :content, :category_id, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar, :avatar_asset_file, :avatar_asset_url )
			end

			def get_article
				@article = Article.friendly.find( params[:id] )
			end


	end
end