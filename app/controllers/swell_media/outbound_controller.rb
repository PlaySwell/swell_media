module SwellMedia
	class OutboundController < ApplicationController


		def show

			if ( @obj = params[:type].constantize.find_by( id: params[:id] ) ).present?

				record_user_event( 'outbound', guest_session: @guest_ession, user: current_user, on: @obj, content: "checked out #{@obj.to_s}." )

				redirect_to ( params[:url] || @obj.try(:url) )

			else

				raise ActionController::RoutingError.new( 'Not Found' )

			end

		end


	end
end