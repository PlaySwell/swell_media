module SwellMedia
	
	class UserAdminController < ApplicationController
		before_filter :authenticate_user!
		layout 'admin'

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

	end

end