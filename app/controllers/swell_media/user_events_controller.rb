module SwellProducts
	class UserEventsController < ApplicationController

		def create

			@parent_obj = params[:parent_obj_type].find(params[:parent_obj_id])

			record_user_event( params[:event], guest_session: @guest_ession, user: current_user, on: @parent_obj, content: params[:content] )

			render text: '200', layout: nil

		end

	end
end