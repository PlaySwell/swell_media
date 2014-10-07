module SwellMedia

	class MediaAsset < ActiveRecord::Base
		self.table_name = 'media_assets'

		mount_uploader :upload, MediaAssetUploader


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		belongs_to :media

		def url
			upload.url || origin_url
		end

	end
	
end