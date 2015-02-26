module SwellMedia
	class StatsAdminController < ApplicationController
		before_filter :authenticate_user!
		layout 'admin'


		def index
			authorize( UserEvent, :admin? )
			
			@stat = params[:stat] || 'visit'
			@start_date = params[:start_date] || 30.days.ago
			@end_date = params[:end_date] || Time.zone.now
			@chart_data = UserEvent.generate_daily_series( @stat, @start_date, @end_date ).map{ |e| '["' + e['date'] + '", ' + e['count'] + ']' }.join( ',' )
		end

	end

end