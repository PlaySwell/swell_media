module SwellMedia
	
	class UserAdminController < ApplicationController
		before_filter :authenticate_user!
		layout 'admin'

		def edit
			@user = User.friendly.find( params[:id] )			
		end


		def index
			authorize( User, :admin? )

			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@users = User.order( "#{sort_by} #{sort_dir}" )

			if params[:q].present?
				@users = @users.where( "name like :q OR first_name like :q OR last_name like :q OR email like :q", q: "%#{params[:q]}%" )
			end

			@users = @users.page( params[:page] )

		end

		def update
			@user = User.friendly.find( params[:id] )
			@user.attributes = user_params

			@user.settings['email_opt_out'] = params[:settings_email_opt_out]

			if @user.save
				set_flash "#{@user} updated"
			else
				set_flash "Could not save", :danger, @user
			end
			redirect_to :back
		end

		private
			def user_params
				params.require( :user ).permit( :name, :first_name, :last_name, :email, :short_bio, :bio, :shipping_name, :address1, :address2, :city, :state, :zip, :phone, :role, :status )
			end

	end

end