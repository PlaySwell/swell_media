module SwellMedia
	class AssetsController < ApplicationController

		before_filter :authenticate_user!

		def new
			@asset = Asset.new

		end

		def create

			@asset = Asset.create( params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status, :uploader, :uploader_cache ) )
			@asset.uploader = params[:file] if params[:file] && params[:asset][:uploader].nil?
			@asset.user = current_user
			@asset.save

			if params[:response] == 'url'
				render text: @asset.url, layout: nil
			else
				redirect_to :back
			end


		end

		def callback_create

			@asset = Asset.create( params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status ).merge({key: params[:key]}) )
			@asset.user = current_user
			@asset.save

			render layout: nil
		end
	end
end