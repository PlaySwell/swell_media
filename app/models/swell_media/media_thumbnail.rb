module SwellMedia

	class MediaThumbnail < ActiveRecord::Base
		# TODO -- kill this in favor of Asset class.....
		self.table_name = 'media_thumbnails'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		belongs_to :media

	end
	
end