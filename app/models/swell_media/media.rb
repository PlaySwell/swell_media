module SwellMedia

	class Media < ActiveRecord::Base
		self.table_name = 'media'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		enum availability: { 'anyone' => 0, 'logged_in_users' => 1, 'just_me' => 2 }

		before_save	:set_publish_at, :set_keywords_and_tags

		validates		:title, presence: true

		attr_accessor	:slug_pref

		belongs_to	:user
		belongs_to 	:managed_by, class_name: 'User'
		belongs_to 	:category

		has_many	:media_thumbnails, dependent: :destroy

		include FriendlyId
		friendly_id :slugger, use: :slugged

		acts_as_nested_set

		acts_as_taggable


		def self.published
			where( 'publish_at <= :now', now: Time.zone.now ).active.anyone
		end



		def author
			if self.properties.present?
				return self.properties['author_name']
			elsif self.user.present?
				return self.user.to_s
			else
				return ''
			end
		end

		def path( args={} )
			path = "/#{self.slug}"

			if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
				path += '?' unless args.empty?
				path += args.map{ |k,v| "#{k}=#{v}"}.join( '&' )
			end
			return path
		end

		def slugger
			self.slug_pref.present? ? self.slug_pref : self.title
		end

		def to_s
			self.title
		end

		def url( args={} )
			domain = ( args.present? && args.delete( :domain ) ) || ENV['APP_DOMAIN'] || 'localhost:3000'
			protocol = ( args.present? && args.delete( :protocol ) ) || 'http'
			path = self.path( args )
			url = "#{protocol}://#{domain}#{self.path( args )}"

			return url

		end


		private

			def set_publish_at
				# set publish_at
				self.publish_at ||= Time.zone.now
			end

			def set_keywords_and_tags
				common_terms = ["able", "about", "above", "across", "after", "almost", "also", "among", "around", "back", "because", "been", "below", "came", "cannot", "come", "cool", "could", "dear", "does", "down", "each", "either", "else", "ever", "every", "find", "first", "from", "from", "gave", "give", "goodhave", "have", "hers", "however", "inside", "into", "its", "just", "least", "like", "likely", "little", "live", "long", "made", "make", "many", "might", "more", "most", "must", "neither", "number", "often", "only", "other", "our", "outside", "over", "part", "people", "place", "rather", "said", "says", "should", "show", "side", "since", "some", "sound", "take", "than", "that", "the", "their", "them",  "then", "there", "these", "they", "thing", "this", "those", "time", "twas", "under", "upon", "was", "wants", "were", "what", "whatever", "when", "where", "which", "while", "whom", "will", "with", "within", "work", "would", "write", "year", "you", "your"]
				
				# auto-tag hashtags
				unless self.description.blank?
					hashtags = self.description.scan( /#\w+/ ).flatten.each{ |tag| tag[0]='' } 
					self.tag_list << hashtags
				end

				self.keywords = "#{self.author} #{self.title}".downcase.split( /\W/ ).delete_if{ |elem| elem.length <= 2 }.delete_if{ |elem| common_terms.include?( elem ) }.uniq
				self.tag_list.each{ |tag| self.keywords << tag.to_s }

				

			end
				


	end

end