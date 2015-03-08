class EventsMigration < ActiveRecord::Migration 

	def change

		enable_extension 'hstore'

		create_table :guest_sessions do |t|
			t.references		:user
			t.string			:src  					# src param used to track campaigns
			t.string			:ui_variant				# var param used to record ui or design variant. e.g. to test colors, layouts, etc.
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
			t.datetime			:session_cluster_created_at
			t.string			:src  					# src param used to track campaigns -- cached here for ease of query
			t.string			:ui_variant				# var param used to record ui or design variant. e.g. to test colors, layouts, etc. gets this from browser session
			t.string			:ui 					# just in case we want to track specific links, buttons, etc. e.g. outbound clicks from 'buy_btn' vs 'info_btn'
			t.references		:category
			t.string			:name
			t.text				:content
			t.integer			:value
			t.string			:http_referrer
			t.string			:req_path
			t.string			:req_full_path
			t.integer			:status, 						default: 1
			t.integer			:availability, 					default: 1 	# anyone, logged_in, just_me
			t.datetime			:publish_at
			t.hstore			:properties
			t.timestamps
		end
		add_index :user_events, [ :created_at, :session_cluster_created_at ], name: 'index_user_events_on_created_at'
		add_index :user_events, [ :user_id, :session_cluster_created_at ], name: 'index_user_events_on_user_id'
		add_index :user_events, [ :user_id, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_user_id_timestamped'
		add_index :user_events, [ :req_path, :session_cluster_created_at ], name: 'index_user_events_on_req_path'
		add_index :user_events, [ :req_path, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_req_path_timestamped'
		add_index :user_events, [ :req_full_path, :session_cluster_created_at ], name: 'index_user_events_on_req_full_path'
		add_index :user_events, [ :req_full_path, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_req_full_path_timestamped'
		add_index :user_events, [ :guest_session_id, :session_cluster_created_at ], name: 'index_user_events_on_guest_session_id'
		add_index :user_events, [ :guest_session_id, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_guest_session_id_timestamped'
		add_index :user_events, [ :parent_obj_id, :parent_obj_type, :session_cluster_created_at ], name: 'index_user_events_on_parent'
		add_index :user_events, [ :parent_obj_id, :parent_obj_type, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_parent_timestamped'
		add_index :user_events, [ :category_id, :session_cluster_created_at ], name: 'index_user_events_on_category_id'
		add_index :user_events, [ :category_id, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_category_id_timestamped'
		add_index :user_events, [ :name, :session_cluster_created_at ], name: 'index_user_events_on_name'
		add_index :user_events, [ :name, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_name_timestamped'
		add_index :user_events, [ :name, :user_id, :session_cluster_created_at ], name: 'index_user_events_on_name_and_user_id'
		add_index :user_events, [ :name, :user_id, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_name_and_user_id_timestamped'
		add_index :user_events, [ :name, :src, :session_cluster_created_at ], name: 'index_user_events_on_name_and_src'
		add_index :user_events, [ :name, :src, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_name_and_src_timestamped'
				
	end

end