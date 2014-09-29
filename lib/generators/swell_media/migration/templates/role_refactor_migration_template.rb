class RoleRefactorMigration < ActiveRecord::Migration
	def change

		add_column :users, :role, :integer, default: 1

		add_column :categories, :avatar, :string

		remove_column :categories, :users_name

		add_column :media, :cached_word_count, :integer

		drop_table :roles

		drop_table :user_roles

	end
end
