module SwellMedia

	class Asset < ActiveRecord::Base
		# this class is for externally hosted (generally media) assets....
		# e.g. photos, video, audio files, web links, etc...
		# intended to be used with CarrierWave / S3 

		self.table_name = 'assets'

		mount_uploader :uploader, AssetUploader, mount_on: :upload if defined?(CarrierWave)


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }

		belongs_to	:user, class_name: SwellMedia.registered_user_class
		belongs_to 	:parent_obj, polymorphic: true

		has_many	:assets, as: :parent_obj, dependent: :destroy

		def non_ajax_uploader( args = {} )

			url = args[:success_action_redirect]
			url ||= SwellMedia::Engine.routes.url_helpers.callback_create_assets_url( { host: SwellMedia.app_host }.merge(args) )

			uploader.success_action_redirect = url
			uploader
		end

		def ajax_uploader( args = {} )

			uploader.success_action_status = '201'
			uploader.use_action_status = true
			uploader
		end

		def url
			try(:uploader).try(:url) || origin_url
		end

		def file=(file)
			if file.present? && defined?(CarrierWave)
				self.uploader.filename = nil
				self.uploader = file
			end
		end

		def key=(key)
			if defined?(CarrierWave)
				filename = key[self.uploader.store_dir.length..-1]
				self.uploader.filename = filename
				super(key)
			end
		end



		def self.avatar
			where(use: 'avatar').order(id: :desc).first
		end

		def self.order_by_avatar_assets( args={} )
			dir = args[:dir] || 'DESC'
			media = args[:media]

			if media.try(:avatar_asset_id)
				order("(id = #{media.avatar_asset_id}) #{dir}, (asset_type = 'image') #{dir}")
			else
				order("(asset_type = 'image') #{dir}")
			end


		end

		def self.order_by_calculated_weight( args={} )
			dir = args[:dir] || 'DESC'
			threshold = args[:threshold] || 0

			res = self.where( "( weight + ((cached_upvote_count - cached_downvote_count) / 2) ) > #{threshold}" )

			res.order( "( weight + cached_upvote_count - cached_downvote_count ) #{dir}" )
		end


		def self.initialize_from_url( url, args = {} )
			asset = Asset.where( "? LIKE ('%' || upload)", url ).first
			asset = Asset.where( origin_url: url ).first unless asset.nil?

			#if the asset exists, and its parent_obj is different than the one provided... copy the asset for this new parent_obj
			if asset && ( args[:parent_obj] && args[:parent_obj] != asset.parent_obj || ( (args[:parent_obj_id] && args[:parent_obj_id] != asset.parent_obj_id) || (args[:parent_obj_type] && args[:parent_obj_type] != asset.parent_obj_type) ) )

				#puts "copying existing asset #{url}"
				asset = Asset.new( { upload: asset.upload, origin_url: asset.origin_url }.merge(args) )

			elsif asset
				#puts "using existing asset #{url}"
			end

			if asset.nil?

				#puts "creating new asset #{url}"
				asset = Asset.new( args )
				asset.origin_url = url
				asset.remote_uploader_url = url if defined?(CarrierWave)

			end

			asset
		end

	end
	
end