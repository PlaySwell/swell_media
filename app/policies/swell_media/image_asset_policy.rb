module SwellMedia
	class ImageAssetPolicy < ApplicationPolicy

		def destroy?
			user.admin? or record.user == user
		end

	end
end