
class SwellMediaV4Migration < ActiveRecord::Migration

	def change
		add_column	:user_events, :activity_obj_id, :integer
		add_column	:user_events, :activity_obj_type, :string
		add_column	:user_events, :value, :integer
		add_column	:user_events, :value_type, :string

		add_index :user_events, [ :activity_obj_id, :activity_obj_type, :session_cluster_created_at ], name: 'index_user_events_on_act_parent'
		add_index :user_events, [ :activity_obj_id, :activity_obj_type, :created_at, :session_cluster_created_at ], name: 'index_user_events_on_act_parent_time'

	end

end