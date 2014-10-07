module SwellMedia
	class MediaAssetsController < ApplicationController

		before_filter :authenticate_user!

		def callback_create

			@asset = MediaAsset.create( params.require( :media_asset ).permit( :media_id, :media_use, :media_type, :name, :caption, :origin_url ) )
			@asset.update_attribute :key, params[:key]

			redirect_to "#{params[:callback]}" unless params[:callback].nil?
			render layout: nil
		end
	end
end