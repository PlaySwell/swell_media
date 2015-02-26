class EventsMigration < ActiveRecord::Migration 

	def change

		enable_extension 'hstore'

		create_table :guest_sessions do |t|
			t.references		:user
			t.string			:src  					# src param used to track campaigns
			t.string			:ip
			t.string			:user_agent
			t.string			:platform
			t.boolean			:mobile
			t.boolean			:tablet
			t.boolean			:human
			t.string			:browser_name
			t.string			:browser_version
			t.string			:language
			t.string			:original_http_referrer
			t.string			:last_http_referrer
			t.hstore 			:params
			t.hstore			:properties
			t.timestamps
		end
		add_index :guest_sessions, :user_id
		add_index :guest_sessions, :src


		create_table :user_events do |t|
			t.references		:user
			t.references		:guest_session
			t.references 		:parent_obj, 			polymorphic: true
			t.string			:src  					# src param used to track campaigns -- cached here for ease of query
			t.references		:category
			t.string			:name
			t.text				:content
			t.integer			:value
			t.string			:http_referrer
			t.string			:req_path
			t.integer			:status, 						default: 1
			t.integer			:availability, 					default: 1 	# anyone, logged_in, just_me
			t.datetime			:publish_at
			t.hstore			:properties
			t.timestamps
		end
		add_index :user_events, :user_id
		add_index :user_events, :guest_session_id
		add_index :user_events, [ :parent_obj_id, :parent_obj_type ], name: 'index_user_events_on_parent'
		add_index :user_events, :category_id
		add_index :user_events, :name
		add_index :user_events, [ :name, :user_id ]
		add_index :user_events, [ :name, :src ]
				
	end

end