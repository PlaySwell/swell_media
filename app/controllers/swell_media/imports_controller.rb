module SwellMedia
	class ImportsController < ApplicationController
		before_filter :authenticate_user!

		def create
			authorize!( :admin, Media )
			
			if count = Importer.import( params[:file] )
				set_flash "#{count} imported"
				redirect_to :back
			else
				set_flash 'Could Not Import.', :error
				redirect_to :back
			end
		end


	end
end