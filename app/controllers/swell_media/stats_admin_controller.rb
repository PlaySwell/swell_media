module SwellMedia
	class StatsAdminController < ApplicationController
		before_filter :authenticate_user!
		layout 'admin'


		def index

			@stat = params[:stat] || 'visit'
			@start_date = params[:start_date] || 30.days.ago
			@end_date = params[:end_data] || Time.zone.now
			@chart_data = UserEvent.generate_daily_series( @stat, @start_date, @end_date )

		end

	end

end