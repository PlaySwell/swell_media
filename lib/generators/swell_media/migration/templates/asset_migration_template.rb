class AssetMigration < ActiveRecord::Migration
	def change

		create_table :assets do |t|
			t.references 	:parent_obj, polymorphic: true
			t.references	:user
			t.string		:title
			t.string		:description # use for caption
			t.text			:content # jic it is a chunk of html or caching entire webpage or something

			t.string		:type # jic want to sti someday....
			t.string		:sub_type # to use e.g. to designate one image as primary avatar
			t.string		:media_use, default: nil
			t.string		:media_type, default: 'image'

			t.string		:origin_name
			t.string		:origin_identifier
			t.string		:origin_url

			t.string		:upload # location for CW?

			t.integer		:height
			t.integer		:width
			t.integer		:duration

			t.integer		:status, 						default: 0
			t.integer		:availability, 					default: 0 	# anyone, logged_in, just_me

			t.hstore		:properties
			t.timestamps
		end
		add_index :assets, [ :parent_obj_type, :parent_obj_id ]

	end
end
