module SwellMedia
	class StaticController < ApplicationController

		after_filter :log_impression

		def home
			# the homepage
		end


		private

			def log_impression
				record_user_event( event: 'page_view', content: "landed on <a href='#{request.url}'>#{controller_name}##{action_name}</a>" )
			end

	end
end