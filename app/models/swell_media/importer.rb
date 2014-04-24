module SwellMedia
	class Importer

		def self.import( file )
			count = 0
			return false if file.nil?

			if file.original_filename.match( /media.+\.csv/i )
				klass = SwellMedia::Media
			elsif file.original_filename.match( /contact.+\.csv/i )
				klass = SwellMedia::Contact
			else
				# file not supported
				return false
			end

			Rails.logger.info ("Importing file: " + file.path )

			csv_text = File.read( file.path )
			csv_text.encode!('utf-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			csv = CSV.parse( csv_text, headers: true )

			csv.each do |row|
				item = klass.new
				item.attributes = row.to_hash.except( 'id', 'lft', 'rgt' ) 
				Rails.logger.info( "\n\nPreparing to save #{item.to_s}" )
				count += 1 if item.save
				Rails.logger.info( "Errors: #{item.errors.inspect}\n\n" ) unless item.valid?
			end

			return count
			
		end

	end
end