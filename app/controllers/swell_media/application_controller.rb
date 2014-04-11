module SwellMedia
	class ApplicationController < ActionController::Base

		before_filter :set_page_info


		rescue_from CanCan::AccessDenied do |exception|
			set_flash exception.message, :error
			redirect_to "/"
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
			@page_info[:title] ||= 'playswell'
			@page_info[:description] ||= 'Share Your Love' 
		end
		

	end
end
