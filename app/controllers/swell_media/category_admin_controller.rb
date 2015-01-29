module SwellMedia
	class CategoryAdminController < ApplicationController
		before_filter :authenticate_user!, except: [ :show ]
		before_filter :get_category, except: [ :create, :empty_trash, :index ]

		layout 'admin'


		def create
			authorize( Category, :admin_create? )
			@category = Category.new( category_params )
			@category.user_id = current_user.id

			if @category.save
				set_flash 'Category Created'
				redirect_to edit_category_admin_path( @category.id )
			else
				set_flash 'Category could not be created', :error, @category
				redirect_to :back
			end
		end

		def destroy
			authorize( @category, :admin_destroy? )
			if @category.trash?
				@category.destroy
			else
				@category.update( status: :trash )
			end
			set_flash 'Category Deleted'
			redirect_to :back
		end

		def edit
			authorize( @category, :admin_edit? )
		end

		def index
			authorize( Category, :admin? )
			
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@categories = Category.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@categories = eval "@categories.#{params[:status]}"
			end

			if params[:q].present?
				@categories = @categories.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@categories = @categories.page( params[:page] )
		end

		def update
			authorize( @category, :admin_update? )
			@category.attributes = category_params

			if @category.save
				set_flash 'Category Updated'
				redirect_to edit_category_admin_path( id: @category.id )
			else
				set_flash 'Category could not be Updated', :error, @category
				render :edit
			end
		end


		private
			def category_params
				params.require( :category ).permit( :name, :display, :slug, :parent_id, :description, :avatar, :status, :type ) # todo
			end

			def get_category
				@category = Category.friendly.find( params[:id] )
			end
	end
end