class Media < ActiveRecord::Base

	before_create 	:prep_media

	validates	:title, presence: true

	attr_accessor	:path

	belongs_to	:user
	belongs_to 	:managed_by, class_name: 'User'
	belongs_to 	:category

	has_many	:media_thumbnails, dependent: :destroy

	include FriendlyId
	friendly_id :slugger, use: :slugged

	acts_as_nested_set

	acts_as_taggable


	def self.active
		where{ ( status.eq 'active' ) & ( availability.eq 'public' ) & ( publish_at.lteq Time.zone.now ) }
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


	def slugger
		self.path.present? ? self.path : self.title
	end

	def to_s
		self.title
	end

	def url( args=nil )
		domain = ( args.present? && args.delete( :domain ) ) || Rails.application.config.playswell_domain
		
		url = "http://#{domain}/#{self.slug}"

		if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
			url += '?' unless args.empty?
			url += args.map{ |k,v| "#{k}=#{v}"}.join( '&' )
		end

		return url

	end


	private

		def prep_media
			# set publish_at
			self.publish_at ||= Time.zone.now

			# set keywords
			if self.title.present?
				common_terms = ["able", "about", "above", "across", "after", "almost", "also", "among", "around", "back", "because", "been", "below", "came", "cannot", "come", "cool", "could", "dear", "does", "down", "each", "either", "else", "ever", "every", "find", "first", "from", "from", "gave", "give", "goodhave", "have", "hers", "however", "inside", "into", "its", "just", "least", "like", "likely", "little", "live", "long", "made", "make", "many", "might", "more", "most", "must", "neither", "number", "often", "only", "other", "our", "outside", "over", "part", "people", "place", "rather", "said", "says", "should", "show", "side", "since", "some", "sound", "take", "than", "that", "the", "their", "them",  "then", "there", "these", "they", "thing", "this", "those", "time", "twas", "under", "upon", "was", "wants", "were", "what", "whatever", "when", "where", "which", "while", "whom", "will", "with", "within", "work", "would", "write", "year", "you", "your"]
				self.keywords = "#{self.author} #{self.title}".downcase.split( /\W/ ).delete_if{ |elem| elem.length <= 2 }.delete_if{ |elem| common_terms.include?( elem ) }.uniq
			end
		end



end



