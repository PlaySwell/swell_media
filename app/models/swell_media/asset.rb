module SwellMedia

	class Asset < ActiveRecord::Base
		# this class is for externally hosted (generally media) assets....
		# e.g. photos, video, audio files, web links, etc...
		# intended to be used with CarrierWave / S3 

		self.table_name = 'assets'

		mount_uploader :upload, AssetUploader


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		belongs_to :parent_obj, polymorphic: true

		def url
			upload.url || origin_url
		end

	end
	
end