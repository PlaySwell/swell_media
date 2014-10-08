module SwellMedia

	class Asset < ActiveRecord::Base
		# this class is for externally hosted (generally media) assets....
		# e.g. photos, video, audio files, web links, etc...
		# intended to be used with CarrierWave / S3 

		self.table_name = 'assets'

		mount_uploader :uploader, AssetUploader, mount_on: :upload if defined?(CarrierWave)


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }

		belongs_to	:user
		belongs_to 	:parent_obj, polymorphic: true

		def url
			try(:uploader).try(:url) || origin_url
		end

		def key=(key)
			if defined?(CarrierWave)
				filename = key[self.uploader.store_dir.length..-1]
				self.uploader.filename = filename
				super(key)
			end
		end

	end
	
end