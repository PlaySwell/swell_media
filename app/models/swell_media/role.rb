module SwellMedia
	class Role < ActiveRecord::Base
		self.table_name = 'roles'
		
		has_many 	:user_roles
		has_many	:users, through: :user_roles
		
	end
end