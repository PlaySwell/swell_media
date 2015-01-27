module SwellMedia
	class CategoriesController < ApplicationController
		before_filter :authenticate_user!, except: [ :show ]
		before_filter :get_category, except: [ :admin, :create, :index ]

		def admin
			authorize( Category )
			@categories = Category.page( params[:page] )
			render layout: 'admin'
		end

		def create
			authorize( Category )
			@category = Category.new( category_params )
			@category.user_id = current_user.id

			if @category.save
				set_flash 'Category Created'
				redirect_to edit_category_path( @category.id )
			else
				set_flash 'Category could not be created', :error, @category
				redirect_to :back
			end
		end

		def destroy
			authorize( @category )
			if @category.trash?
				@category.destroy
			else
				@category.update( status: :trash )
			end
			set_flash 'Category Deleted'
			redirect_to :back
		end

		def edit
			authorize( @category )
			render layout: 'admin'
		end

		def update
			authorize( @category )
			@category.attributes = category_params

			if @category.save
				set_flash 'Category Updated'
				redirect_to edit_category_path( id: @category.id )
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