module SwellMedia
	class MediaRelationship < ActiveRecord::Base

		belongs_to :user # who proposed the relationship
		belongs_to :media
		belongs_to :related_media, class_name: 'Media'

	end
end