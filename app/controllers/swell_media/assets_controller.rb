module SwellMedia
	class AssetsController < ApplicationController

		before_filter :authenticate_user!

		def new
			@asset = Asset.new

		end

		def create

			if params[:asset][:url]
				@asset = Asset.initialize_from_url( params[:asset][:url], params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status ) )
			else
				@asset = Asset.create( params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status, :uploader ).merge( file: params[:file] ) )

			end

			@asset.user = current_user

			if !@asset.save

				set_flash 'Unable to Save', :error
				redirect_to :back

			elsif params[:response] == 'url'

				render text: @asset.url, layout: nil

			elsif request.env['HTTP_REFERER']

				begin
					uri =  URI.parse(request.env['HTTP_REFERER'])
					new_query_ar = URI.decode_www_form(uri.query || '') << ["asset_url", @asset.url]
					uri.query = URI.encode_www_form(new_query_ar)

					redirect_to uri.to_s
				rescue
					redirect_to :back
				end

			else

				redirect_to :back

			end


		end

		def destroy
			@asset = Asset.find(params[:id])
			authorize( @asset )

			@asset.update( status: 'trash' )

			redirect_to :back
		end

		def callback_create

			@asset = Asset.create( params.require( :asset ).permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status ).merge({key: params[:key]}) )
			@asset.user = current_user
			@asset.save

			if params[:async]

				render layout: nil

			elsif params[:redirect_to]

				uri =  URI.parse(params[:redirect_to])
				new_query_ar = URI.decode_www_form(uri.query) << ["asset_url", @asset.url]
				uri.query = URI.encode_www_form(new_query_ar)
				redirect_to uri.to_s

			end
		end
	end
end