module SwellMedia

	class ApiAccessTokenController < ActionController::Base

		def create

			session = GuestSession.create_from_request( request, params: params )

			session.traffic_source ||= params[:utm_source]
			session.traffic_medium ||= params[:utm_medium]
			session.traffic_campaign ||= params[:utm_campaign]

			if params[:src].present?
				session.traffic_src_user = params[:src] #User.find_by( slug: params[:src] ).try( :slug )
			end

			session.access_token = SecureRandom.uuid
			session.device_id = params[:device_id]

			session.last_http_referrer = request.referrer

			session.save

			# @todo verify credentials and login user to session

			render json: { access_token: session.access_token }

		end

		def show

			session = GuestSession.find_by( access_token: params[:id], device_id: params[:api_access_device_id] )

			render json: { access_token: session.access_token, user_id: session.user_id }

		end

	end

end