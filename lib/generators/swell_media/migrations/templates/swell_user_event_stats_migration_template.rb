class SwellUserEventStatsMigration < ActiveRecord::Migration

	def change

		create_table "user_event_stats", force: :cascade do |t|
			t.string  "event_name"
			t.integer "event_count",     default: 0
			t.date    "starts_at"
			t.date    "ends_at"
		end

		add_index "user_event_stats", ["event_name", "starts_at", "event_count", "ends_at"], name: "idx_user_event_stats_on_event_name_and_starts_at"
		add_index "user_event_stats", ["event_name", "starts_at", "ends_at"], name: "idx_user_event_stats_on_event_name_and_starts_and_ends_at"


	end
end
