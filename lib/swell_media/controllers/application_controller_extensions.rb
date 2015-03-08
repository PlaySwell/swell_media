
module SwellMedia
	module ApplicationControllerExtensions
		include Pundit

		def assign_anonymous_events( user=current_user )
			# fired when a user logs in or registers...
			# links guest_session to user
			if session = GuestSession.find_by( id: cookies.signed[:guest] )
				session.update( user_id: user.id )
			end
		end


		def record_user_event( event='visit', args={} )
			# this method can be called by any controller to log a specific event
			# such as a purchase, comment, newsletter signup, etc.
			return false unless SwellMedia.log_events
			args[:request] ||= request
			
			args[:user] ||= current_user

			args[:ga_client_id] ||= session[:ga_client_id]
			args[:guest_session] ||= @guest_session
			args[:session_cluster_created_at] ||= @session_cluster_created_at

			args[:req_path] ||= request.fullpath

			if user_event = EventService.log( event, args )
				# this is here in the controller so we can access request obj, cookies, etc. if it results in another UserEvent
				# should move into a cron....
				return user_event
			else
				return false
			end
		end


		def set_dest
			if params[:dest].present?
				session[:dest] = params[:dest]
			elsif (		current_user.nil? &&
						request.get? &&
						not( params[:controller].match( /\outbound/ ) ) &&
						not( request.fullpath.match( /\/users/ ) ) &&
						not( request.fullpath.match( /\/login/ ) ) &&
						not( request.fullpath.match( /\/logout/ ) ) &&
						not( request.fullpath.match( /\/register/ ) ) &&
						!request.xhr? ) # don't store ajax calls
				session[:dest] = request.fullpath
			end
		end


		def set_ga_client_id
			session[:ga_client_id] = params[:ga_client_id] if params[:ga_client_id].present?
		end


		def set_flash( msg, code=:success, *objs )
			if flash[code].blank?
				flash[code] = "<p>#{msg}</p>"
			else
				flash[code] += "<p>#{msg}</p>"
			end
			objs.each do |obj|
				obj.errors.each do |error|
					flash[code] += "<p>#{error.to_s}: #{obj.errors[error].join(';')}</p>"
				end
			end
		end


		def set_guest_session

			#place cookie, which tracks the start time of a session.  A session being any period of activity, ending with a
			#period of at least 30 minutes of inactivity... hence the cookie length.
			@session_cluster_created_at = Time.at(cookies.signed[:session_cluster] || Time.zone.now.to_i)
			cookies.signed[:session_cluster] = { value: @session_cluster_created_at.to_i, expires: SwellMedia.max_session_inactivity.from_now }

			if session = GuestSession.where( id: cookies.signed[:guest] ).first
				session.update( last_http_referrer: request.referrer )
				return session
			else
				session = GuestSession.create_from_request( request, params: params, user: current_user )
				cookies.signed[:guest] = { value: session.id, expires: 1.year.from_now }
				return session
			end
		end


		def set_page_meta( args={} )
			args[:og] ||= {}
			args[:twitter] ||= {}
			@page_meta = args
			
			@page_meta[:title] ||= SwellMedia.app_name
			@page_meta[:description] ||= SwellMedia.app_description
			@page_meta[:image] ||= SwellMedia.app_logo

			@page_meta[:site_name] ||= SwellMedia.app_name
			@page_meta[:fb_type] ||= 'article' # blog, website
			@page_meta[:url] ||= request.url

			@page_meta[:twitter_format] ||= 'summary'
			@page_meta[:twitter_site] ||= SwellMedia.twitter_handle

		end


		# def set_ref_user
		# 	# if the ref is present and (if logged in the ref is not that of the current user) then
		# 	# cookie the user with that ref.
		# 	ref_user = nil
		# 	if params[:ref].present? && ( params[:ref] != current_user.try(:slug) && params[:ref] != current_user.try(:id) )
		# 		ref_user = User.where( slug: params[:ref] ).first || User.where( id: params[:ref] ).first
	 #      		# referrer cookie is always user.id
		# 		cookies.signed[:ref] = { value: ref_user.id, expires: 30.days.from_now } if ref_user.present?
		# 		cookies.signed[:rec] = { value: ref_user.id, expires: 30.days.from_now, path: request.path } if ref_user.present?
		# 	else
		# 		ref_user = User.where( id: cookies.signed[:ref] ).first if cookies.signed[:ref].present?
		# 	end

		# 	return ref_user == current_user ? nil : ref_user
		# end



	end

end