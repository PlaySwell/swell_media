class AssetMigration < ActiveRecord::Migration
	def change

		create_table :assets do |t|
			t.references	:parent_obj, 			polymorphic: true
			t.string		:title
			t.string		:caption

			t.string		:use, default: nil
			t.string		:asset_type, default: 'image'

			t.string		:origin_name
			t.string		:origin_identifier
			t.text			:origin_url

			t.text			:upload

			t.integer		:height
			t.integer		:width
			t.integer		:status, 						default: 0
			t.integer		:availability, 					default: 0 	# anyone, logged_in, just_me

			t.hstore		:properties
			t.timestamps
		end
		add_index :assets, [:parent_obj_id, :parent_obj_type, :asset_type, :use], name: 'swell_media_asset_use_index'

	end
end
