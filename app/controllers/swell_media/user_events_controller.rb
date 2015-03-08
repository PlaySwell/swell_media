module SwellMedia
	class UserEventsController < ApplicationController

		def create

			@parent_obj = params[:parent_obj_type].constantize.find_by(id: params[:parent_obj_id]) unless params[:parent_obj_type].nil? || params[:parent_obj_id].nil?

			#opt_out_google_analytics: true - front end will be posting it to GA more completely anyways... dont want double data.
			record_user_event( params[:event], guest_session: @guest_ession, user: current_user, on: @parent_obj, content: params[:content], opt_out_google_analytics: true )

			render text: '200', layout: nil

		end

	end
end