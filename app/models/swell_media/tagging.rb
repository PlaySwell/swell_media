module SwellMedia
	class Tagging < ActiveRecord::Base
		self.table_name = 'taggings'


		belongs_to 	:tag # who added the product...
		belongs_to 	:tagger, polymorphic: true
		belongs_to 	:taggable, polymorphic: true

	end
end