module SwellMedia

	class Asset < ActiveRecord::Base
		self.table_name = 'assets'

		mount_uploader :uploader, AssetUploader, mount_on: :upload


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		belongs_to :parent_obj, polymorphic: true

		def url
			uploader.url || origin_url
		end

	end
	
end