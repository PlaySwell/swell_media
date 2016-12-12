module SwellMedia
	class AssetPolicy < ApplicationPolicy

		def destroy?
			user.admin? or record.user == user
		end

	end
end