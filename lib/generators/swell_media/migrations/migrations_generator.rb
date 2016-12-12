
require 'rails/generators/migration'

module SwellMedia
	module Generators

		class MigrationsGenerator < ::Rails::Generators::Base
			include Rails::Generators::Migration
			source_root File.expand_path( '../templates', __FILE__ )
			desc "add the migrations"
			
			def self.next_migration_number( path )
				unless @prev_migration_nr
					@prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
				else
					@prev_migration_nr += 1
				end
				@prev_migration_nr.to_s
			end

			def copy_migrations
				migration_template "swell_users_migration_template.rb", "db/migrate/swell_users_migration.rb"
				migration_template "swell_media_migration_template.rb", "db/migrate/swell_media_migration.rb"
				migration_template "swell_assets_migration_template.rb", "db/migrate/swell_assets_migration.rb"
				migration_template "swell_events_migration_template.rb", "db/migrate/swell_events_migration.rb"
			end

		end
	end
end