# encoding: utf-8

if defined?(CarrierWave)

	class AssetUploader < CarrierWave::Uploader::Base
		#include CarrierWaveDirect::Uploader if defined?(CarrierWaveDirect)

		storage :fog

		def asset_host
			ENV['ASSET_HOST'] || super
		end

		# Override the directory where uploaded files will be stored.
		# This is a sensible default for uploaders that are meant to be mounted:
		def store_dir
			'assets/'
		end

		# Override the filename of the uploaded files:
		# Avoid using model.id or version_name here, see uploader/store.rb for details.
		def filename
			@name = model.upload
			@name ||= construct_new_file_name(file.extension) if original_filename
			#@name ||= construct_new_file_name()
			@name
		end

		def filename=(filename)
			@name = filename
		end

		#def extension_white_list
		#	%w(jpg jpeg gif png)
		#end

		def construct_new_file_name(extension = nil)

			fname = "#{SecureRandom.uuid}"

			fname = "#{fname}.#{extension}" if !extension.blank? #&& extension_white_list.include?(extension)

			fname
		end
	end

else

	class AssetUploader

	end

end
