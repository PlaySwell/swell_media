# each type of media responsible for it's own admin/create/edit/update/etc 
# each lives at a root url /slug and show is delegated to media controller

module SwellMedia
	class PagesController < SwellMedia::MediaController
		
		before_filter :authenticate_user!, except: [ :show ]
		before_filter :get_page, except: [ :admin, :create, :index ]

		def admin
			authorize( Page )
			
			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@pages = Page.order( "#{sort_by} #{sort_dir}" )

			if params[:q].present?
				@pages = @pages.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@pages = @pages.page( params[:page] )
			render layout: 'admin'
		end


		def create
			authorize( Page )
			@page = Page.new( page_params )
			@page.publish_at ||= Time.zone.now
			@page.status = 'draft'
			if @page.save
				set_flash 'Page Created'
				redirect_to edit_page_path( @page.id )
			else
				set_flash 'Page could not be created', :error, @page
				redirect_to :back
			end
		end


		def destroy
			authorize( @page )
			@page.update( status: 'trash' )
			set_flash 'Page Trashed'
			redirect_to :back
		end


		def edit
			authorize( @page )
			render layout: 'admin'
		end


		def update
			authorize( @page )
			
			@page.slug = nil if params[:page][:slug_pref].present? || params[:page][:title] != @page.title
			@page.attributes = page_params

			if @page.save
				set_flash 'Article Updated'
				redirect_to edit_page_path( id: @page.id )
			else
				set_flash 'Article could not be Updated', :error, @page
				render :edit
			end
		end

		private
			def page_params
				params.require( :page ).permit( :title, :subtitle, :slug_pref, :description, :content, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar, :avatar_asset_file, :avatar_asset_url )
			end

			def get_page
				@page = Page.friendly.find( params[:id] )
			end
		
	end
end