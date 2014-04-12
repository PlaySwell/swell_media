module SwellMedia
	module Generators

		class ViewsGenerator < Rails::Generators::Base
			desc "Copies SwellMedia views to your application."
			puts "Copies SwellMedia views to your application."
			include Thor::Actions

			source_root File.expand_path( '../../../app/views', __FILE__ )

			# Copy all of the views from the swell_media/app/views/swell_media to
			# app/views/swell_media
			def copy_views
				directory 'swell_media', 'app/views/swell_media'
			end

		end
	end
end