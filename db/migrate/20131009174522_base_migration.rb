class BaseMigration < ActiveRecord::Migration
	def change

		#enable_extension 'hstore'

		create_table :media do |t|
			t.references	:user 					# User who added it
			t.references	:managed_by 			# User acct that has origin acct (e.g. youtube) rights
			t.string		:public_id				# public id to spoof sequential id grepping
			t.references 	:category
			t.references	:organization 			# managing organization

			t.references	:parent_obj, 	polymorphic: true # for comments
			t.references	:parent 				# for nested_set (podcasts + episodes, conversations, etc.)
			t.integer		:lft
			t.integer		:rgt

			t.string		:type 					# video, product, page, article, etc...
			t.string		:sub_type				# video, tv, dvd

			t.references	:media_origin 			# youtube, amazon, etc...
			t.string		:origin_identifier		# YT_ID, ASIN, etc...
			t.string		:origin_domain
			t.string		:origin_url

			t.string		:title
			t.string		:subtitle
			t.string		:avatar
			t.text			:description
			t.text			:content
			t.string		:slug

			t.integer		:reward_threshold,				default: 100  # if product needs this many kudos to be offered as a reward

			t.boolean 		:is_commentable, 				default: true
			t.boolean		:is_sticky,						default: false 		# for forum topics
			t.boolean		:show_title,					default: true
			t.datetime		:modified_at 								# because updated_at is inadequate when caching stats, etc.
			t.text			:keywords, 	array: true, 		default: []

			t.string		:duration
			t.integer		:price

			t.integer 		:cached_impression_count, 		default: 0, 	limit: 8
			t.integer 		:cached_play_count, 			default: 0, 	limit: 8
			t.integer 		:cached_view_count, 			default: 0, 	limit: 8
			t.integer 		:cached_complete_count, 		default: 0, 	limit: 8

			t.float 		:cached_play_rate,				default: 0 # play_count / impression_count
			t.float 		:cached_view_rate,				default: 0 # view_count / impression_count
			t.float 		:cached_complete_rate,			default: 0 # complete_count / impression_count
			t.float 		:cached_upvote_rate,			default: 0 # upvote_count / impression_count

			t.integer 		:cached_comment_count, 			default: 0, 	limit: 8
			t.integer 		:cached_outbound_count, 		default: 0, 	limit: 8

			t.integer 		:cached_investment_count, 		default: 0, 	limit: 8
			t.integer 		:cached_investment_total, 		default: 0, 	limit: 8
			t.integer 		:cached_share_count, 			default: 0, 	limit: 8

			t.integer		:cached_vote_count,				default: 0, 	limit: 8
			t.float			:cached_vote_score,				default: 0
			t.integer		:cached_upvote_count,			default: 0, 	limit: 8
			t.integer		:cached_downvote_count,			default: 0, 	limit: 8
			t.integer		:cached_subscribe_count, 		default: 0

			t.float			:score,							default: 0
			t.float			:previous_score,				default: 0
			t.float 		:decayed_score,					default: 0
			t.datetime		:score_updated_at


			t.string		:status, 						default: :active
			t.string		:availability, 					default: :public 	# hidden, friends, peers,
			t.datetime		:publish_at
			#t.hstore		:properties

			t.timestamps
		end

		add_index :media, :user_id
		add_index :media, :managed_by_id
		add_index :media, :public_id
		add_index :media, :category_id
		add_index :media, :organization_id
		add_index :media, :media_origin_id
		add_index :media, :origin_identifier
		add_index :media, :slug, unique: true
		add_index :media, [ :slug, :type ]
		add_index :media, [ :status, :availability ]


		# video_origin is the host service. Different origins will have different players, etc...
		create_table :media_origins do |t|
			t.text			:name
			t.string		:slug
			t.string		:affiliate_code 	# our affiliate code
			t.string		:default_player 	# this is some indication of player skin e.g. brightcove supports different player 'skins'
			t.string		:default_player_key
		end
		add_index :media_origins, :name


		create_table :media_relationships do |t|
			t.references 		:media
			t.references		:related_media
			t.references		:user
			t.references		:category
			t.float				:weight, 			default: 0
			t.string			:relation_type, 	default: 'inferred'
			t.string			:status,			default: :active
			t.timestamps
		end
		add_index :media_relationships, :user_id
		add_index :media_relationships, :media_id
		add_index :media_relationships, :category_id
		add_index :media_relationships, :related_media_id


		# to store thumbnail data....
		create_table :media_thumbnails do |t|
			t.references 	:media
			t.string		:name
			t.string		:url
			t.integer		:height
			t.integer		:width
			t.string		:status, 							default: :active
			t.timestamps
		end
		add_index	:media_thumbnails, :media_id

	end
end
