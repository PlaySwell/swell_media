class AssetMigration < ActiveRecord::Migration
	def change

		create_table :media_assets do |t|
			t.references 	:media
			t.string		:name
			t.string		:caption

			t.string		:media_use, default: nil
			t.string		:media_type, default: 'image'

			t.string		:origin_name
			t.string		:origin_identifier
			t.string		:origin_url

			t.string		:upload

			t.integer		:height
			t.integer		:width
			t.integer		:status, 						default: 0
			t.integer		:availability, 					default: 0 	# anyone, logged_in, just_me

			t.hstore		:properties
			t.timestamps
		end
		add_index :media_assets, [:media_id, :media_type, :media_use]

	end
end
