module SwellMedia
	class MediaThumbnail < ActiveRecord::Base
		self.table_name = 'media_thumbnails'
		
		belongs_to :media

	end
end