class SearchMigration < ActiveRecord::Migration
	def up
		# 1. Create the search vector column
		add_column :media, :search_vector, 'tsvector'

		# 2. Create the gin index on the search vector
		execute <<-SQL
      CREATE INDEX media_search_idx
      ON media
      USING gin(search_vector);
		SQL

		# 4 (optional). Trigger to update the vector column
		# when the medias table is updated
		execute <<-SQL
      DROP TRIGGER IF EXISTS media_search_vector_update
      ON media;
      CREATE TRIGGER media_search_vector_update
      BEFORE INSERT OR UPDATE
      ON media
      FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger (search_vector, 'pg_catalog.english', title, description, content);
		SQL

		SwellMedia::Media.find_each { |p| p.touch }
	end

	def down
		remove_column :media, :search_vector
		execute <<-SQL
      DROP TRIGGER IF EXISTS media_search_vector_update on media;
		SQL
	end
end