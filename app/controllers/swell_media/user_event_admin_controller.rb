module SwellMedia
	class UserEventAdminController < ApplicationController

		before_filter :authenticate_user!

		layout 'admin'

		def index
			authorize( UserEvent, :admin? )
				
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@events = UserEvent.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@events = eval "@events.#{params[:status]}"
			end

			if params[:event_name].present? && params[:event_name] != 'all'
				@events = @events.where( name: params[:event_name] )
			end

			if params[:q].present?
				@events = @events.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@count = @events.count

			@events = @events.page( params[:page] )
			
		end
	end
end