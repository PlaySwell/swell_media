module SwellMedia
	class OutboundController < ApplicationController


		def show

			@obj = params[:type].constantize.find_by( id: params[:id] )
			url = @obj.try( :origin_url ) || params[:url]

			host = Addressable::URI.parse( url ).host
			
			if @obj && not( url.blank? )
				record_user_event( on: @obj, content: "checked out #{@obj.to_s}: #{url}." )
				redirect_to( url )
			else
				raise ActionController::RoutingError.new( 'Not Found' )
			end

		end


	end
end