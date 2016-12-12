module SwellMedia
	module Concerns

		module AvatarAsset
			extend ActiveSupport::Concern

			def avatar_asset_file=( file )
				return false unless file.present?
				asset = ImageAsset.new(use: 'avatar', asset_type: 'image', status: 'active')
				asset.uploader = file
				asset.save
				asset.parent_obj = self
				assets << asset

				self.avatar_asset = asset
				self.avatar = asset.try(:url)
			end

			def avatar_asset_url
				nil
			end

			def avatar_asset_url=( url )
				return false unless url.present?

				puts "avatar_asset_url=( #{url} )"

				asset = ImageAsset.new( use: 'avatar', asset_type: 'image', status: 'active', origin_url: url, remote_uploader_url: url )

				if asset.save
					puts "avatar_asset_url=( #{url} ) SAVE"
					asset.parent_obj = self
					assets << asset

					self.avatar_asset = asset
				else

					puts "avatar_asset_url=( #{url} ) errors #{asset.errors.full_messages}"

				end

			end

			def avatar_asset_id=( id )
				puts "avatar_asset_id=( id )"
				super(id)
				self.avatar = Asset.find(id).url
			end

			def avatar_asset=( asset )
				puts "avatar_asset=( asset )"
				super(asset)
				self.avatar = asset.url
			end
		end
	end
end