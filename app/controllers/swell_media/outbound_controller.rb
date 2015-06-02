module SwellMedia
	class OutboundController < ApplicationController


		def show

			@obj = params[:type].constantize.find_by( id: params[:id] )
			url = @obj.try( :origin_url ) || params[:url]

			if @obj && not( url.blank? )
				record_user_event( 'outbound', on: @obj, ui: params[:ui], content: "checked out #{@obj.to_s}: #{url}." )
				redirect_to( url )
			else
				raise ActionController::RoutingError.new( 'Not Found' )
			end

		end


	end
end