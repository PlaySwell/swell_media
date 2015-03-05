module SwellProducts
	class UserEventsController < ApplicationController

		def create

			if ( @parent_obj = params[:parent_obj_type].constantize.find_by(id: params[:parent_obj_id]) ).present?

				record_user_event( params[:event], guest_session: @guest_ession, user: current_user, on: @parent_obj, content: params[:content] )

				render text: '200', layout: nil

			else

				raise ActionController::RoutingError.new( 'Not Found' )

			end


		end

	end
end