module SwellMedia
	class MediaController < ApplicationController
		# only used for global admin (any media) and preview.
		# media#show should route to root controller for naked paths (e.g. domain/slug )
		# or to the controller of choice for scoped paths (e.g. domain/blog/id to articles#show )

		before_filter :authenticate_user!, only: [ :admin, :create, :destroy, :edit, :update ]
		before_filter :get_media, only: [ :destroy, :edit, :preview, :update ]

		def admin
			authorize( Media )
			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@media = controller_name.classify.constantize.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@media = eval "@media.#{params[:status]}"
			end

			if params[:q].present?
				@media = @media.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@media = @media.page( params[:page] )

			render layout: 'admin'
		end

		def create
			authorize( Media )
			if params[:media_type].present?
				@media = params[:media_type].constantize.new( media_params )
			else
				@media = Media.new( media_params )
			end

			@media.publish_at ||= Time.zone.now
			@media.user = current_user
			@media.status = 'draft'

			if name = params[:media][:category_name]
				@media.category = SwellMedia::Category.where( name: name ).first_or_create( status: 'active' ) unless name.blank?
			end

			if @media.save
				record_user_event( 'publish', user: current_user, on: @media, content: "published <a href='#{@media.url}'>#{@media.to_s}</a>" ) if defined?( SwellPlay )
				set_flash 'Media Created'
				redirect_to edit_media_path( @media )
			else
				set_flash 'Media could not be created', :error, @media
				redirect_to :back
			end
		end

		def destroy
			authorize( Media )
			if params[:permanent]
				@media.destroy
			else
				@media.trash!
			end
			set_flash "#{@media.class.name.demodulize} Deleted"
			redirect_to :back
		end

		def edit
			authorize( @media )
			render layout: 'admin'
		end

		def index
			@media = Media.published.order( publish_at: :desc )
			@tags = Media.published.tag_counts

			if @tagged = params[:tagged]
				@media = @media.tagged_with( @tagged )
			end

			if @keyword = params[:keyword]
				@media = @media.where( "array[:term] && keywords", term: @keyword )
			end

			if params[:by].present? && @author = User.friendly.find( params[:by] )
				@media = @media.where( user_id: @author.id )
			end

			cat = params[:category] || params[:cat]

			if cat.present? && @category = Category.friendly.find( cat )		
				@media = @media.where( category_id: @category.id )
			end

			if params[:q].present?
				@query = params[:q]
				@media = @media.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			# set count before pagination
			@count = @media.count

			@media = @media.page( params[:page] )

			set_page_meta title: "Media", og: { type: 'blog' }, twitter: { card: 'summary' }

		end

		def preview
			authorize( @media )

			layout = @media.slug == 'homepage' ? 'swell_media/homepage' : "#{@media.class.name.underscore.pluralize}"
			render "#{@media.class.name.underscore.pluralize}/show"
		end


		def update
			authorize( @media )
			
			@media.slug = nil if params[:media][:slug_pref].present? || params[:media][:title] != @media.title
			@media.attributes = media_params

			if name = params[:media][:category_name]
				@media.category = SwellMedia::Category.where( name: name ).first_or_create( status: 'active' ) unless name.blank?
			end

			if @media.save
				set_flash 'Media Updated'
				redirect_to edit_media_path( id: @media.id )
			else
				set_flash 'Article could not be Updated', :error, @media
				render :edit
			end
			
		end


		private

			def get_media
				@media = Media.friendly.find( params[:id] )
			end

			def media_params
				params.require( :media ).permit( :title, :subtitle, :slug_pref, :description, :content, :category_id, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar, :avatar_asset_file, :avatar_asset_url )
			end


		end
end