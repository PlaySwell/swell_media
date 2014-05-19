
module SwellMedia
	module ApplicationControllerExtensions
		
		
		def after_sign_in_path_for( resource )
	 		if resource.has_role?( :admin )
	 			return admin_index_path
	 		elsif session[:dest].present?
	 			return session[:dest].to_s
	 		else
	 			return dash_index_path
	 		end
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


		def set_page_info( args={} )
			@page_info = args
			@page_info[:title] ||= ENV['APP_NAME']
			@page_info[:description] ||= ENV['APP_DESCRIPTION'] 

		end


		def set_dest
			if params[:dest].present?
				session[:dest] = params[:dest]
			elsif (		current_user.nil? &&
						not( request.fullpath.match( /\/users/ ) ) &&
						request.fullpath != login_path &&
						request.fullpath != register_path &&
						request.fullpath != logout_path &&
						!request.xhr? ) # don't store ajax calls
				session[:dest] = request.fullpath
			end
		end


	end

end