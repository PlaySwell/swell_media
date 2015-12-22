module SwellMedia
	class UserEventsController < ApplicationController

		def create

			opt_out_google_analytics = true
			opt_out_google_analytics = false if params[:ga]

			@parent_obj = params[:parent_obj_type].constantize.find_by(id: params[:parent_obj_id]) unless params[:parent_obj_type].nil? || params[:parent_obj_id].nil?
			@activity_obj = params[:activity_obj_type].constantize.find_by(id: params[:activity_obj_id]) unless params[:activity_obj_type].nil? || params[:activity_obj_id].nil?

			@user = current_user
			@user = User.where( email: params[:email] ).first if params[:email].present?

			#opt_out_google_analytics: true - front end will be posting it to GA more completely anyways... dont want double data.
			args = { event: params[:event], guest_session: @guest_ession, user: @user, on: @parent_obj, obj: @activity_obj, content: params[:content], opt_out_google_analytics: opt_out_google_analytics, rate: 1.second, parent_controller: params[:parent_controller], parent_action: params[:parent_action] }

			record_user_event( args )

			render text: '200', layout: nil

		end

	end
end