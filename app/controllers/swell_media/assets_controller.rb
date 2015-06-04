module SwellMedia
	class AssetsController < ApplicationController

		before_filter :authenticate_user!

		def new
			@asset = Asset.new

			respond_to do |format|
				format.json {

					@uploader = @asset.ajax_uploader

					render :json => {
						request: {
							:utf8 => '',
							:key => @uploader.key,
							'AwsAccessKeyId' => @uploader.aws_access_key_id,
							:acl => @uploader.acl,
							:success_action_status => @uploader.success_action_status,
							:policy => @uploader.policy,
							:signature => @uploader.signature
						},
						action: @uploader.direct_fog_url,
						callback: {
								url: swell_media.callback_create_assets_path( format: :json ),
								data: params[:asset] || {}
						}
					}
				}
				format.html {
					render layout: 'swell_media/assets'
				}
			end
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

			@asset = Asset.create( params.permit( :parent_obj_id, :parent_obj_type, :use, :asset_type, :title, :description, :type, :sub_type, :status ) )
			@asset.user = current_user
			@asset.save

			Asset.where( id: @asset.id, upload: nil ).update_all( upload: (params[:key] || '').gsub(/assets\/+/, '') )
			@asset.reload

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