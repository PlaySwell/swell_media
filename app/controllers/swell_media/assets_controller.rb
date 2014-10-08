module SwellMedia
	class AssetsController < ApplicationController

		before_filter :authenticate_user!

		def callback_create

			@asset = Asset.create( params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :media_use, :media_type, :name, :caption, :origin_url ) )

			filename = params[:key][@asset.uploader.store_dir.length..-1]
			logger.info "update_attribute key #{filename}"
			@asset.upload = filename
			if !@asset.save
				logger.info "ERROR #{@asset.errors.full_messages}"
			end
			logger.info @asset.key

			#@asset = MediaAsset.find(@asset.id)

			#redirect_to "#{params[:callback]}" unless params[:callback].nil?
			render layout: nil
		end
	end
end