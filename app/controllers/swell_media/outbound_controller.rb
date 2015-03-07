module SwellMedia
	class OutboundController < ApplicationController


		def show

			if @obj = params[:type].constantize.find_by( id: params[:id] )

				url = @obj.try( :origin_url ) || @obj.try( :url )

				record_user_event( 'outbound', on: @obj, content: "checked out #{@obj.to_s}." )

				redirect_to( params[:url] || url )
			else
				raise ActionController::RoutingError.new( 'Not Found' )
			end

		end


	end
end