
module SwellMedia
	module ApplicationControllerExtensions
		include Pundit
	
		def after_sign_in_path_for( resource )
	 		if resource.admin? || resource.contributor?
	 			return admin_index_path
	 		elsif session[:dest].present?
	 			return session[:dest].to_s
	 		else
	 			return '/'
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


		def set_page_meta( args={} )
			args[:og] ||= {}
			@page_meta = args
			
			@page_meta[:title] ||= ENV['APP_NAME']
			@page_meta[:description] ||= ENV['APP_DESCRIPTION']

			@page_meta[:og][:site_name] ||= ENV['APP_NAME']
			@page_meta[:og][:title] ||= @page_meta[:title]
			@page_meta[:og][:type] ||= 'article' # blog, website
			@page_meta[:og][:url] ||= request.url

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


	end

end