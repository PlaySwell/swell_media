module SwellMedia

	class ImageAsset < SwellMedia::Asset

		after_create :update_dimensions


		def update_dimensions

			dimensions = FastImage.size(self.url, :raise_on_failure=>false, :timeout=>2.0)
			self.update(width: dimensions[0], height: dimensions[1]) if dimensions.present?

		end

	end

end