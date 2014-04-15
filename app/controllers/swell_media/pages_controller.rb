# each type of media responsible for it's own admin/create/edit/update/etc 
# each lives at a root url /slug and show is delegated to media controller

module SwellMedia
	class PagesController < SwellMedia::MediaController
		
		before_filter :authenticate_user!, except: [ :show ]
		before_filter :get_page, except: [ :admin, :create, :index ]

		def admin
			authorize! :admin, SwellMedia::Page
			@pages = Page.page( params[:page] )
			render layout: 'admin'
		end


		def create
			authorize!( :admin, Page )
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
			authorize!( :admin, Page )
			@page.update( status: 'deleted' )
			set_flash 'Page Deleted'
			redirect_to :back
		end


		def edit
			authorize!( :admin, Page )
			render layout: 'admin'
		end


		def update
			authorize!( :admin, Page )
			
			@page.slug = nil if params[:page][:path].present? || params[:page][:title] != @page.title
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
				params.require( :page ).permit( :title, :subtitle, :path, :description, :content, :status, :publish_at, :show_title, :is_commentable, :user_id, :tag_list, :avatar )
			end

			def get_page
				@page = Page.friendly.find( params[:id] )
			end
		
	end
end