1
module SwellMedia
	module ApplicationControllerExtensions
		
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

	end

end