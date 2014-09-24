class RoleRefactorMigration < ActiveRecord::Migration
	def change

		drop_table :roles

		drop_table :user_roles

		add_column :users, :role, :integer, default: 1

	end
end
