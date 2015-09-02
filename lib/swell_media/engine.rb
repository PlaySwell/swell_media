# require 'acts-as-taggable-on'
require 'acts-as-taggable-array-on'
require 'awesome_nested_set'
require 'browser'
require 'devise'
require 'friendly_id'
require 'haml'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'pundit'
require 'swell_media/controllers/application_controller_extensions'
require 'fb_graph'
require 'staccato'

module SwellMedia

	class << self
		mattr_accessor :log_events
		mattr_accessor :app_name
		mattr_accessor :app_host
		mattr_accessor :asset_host
		mattr_accessor :app_description
		mattr_accessor :app_logo
		mattr_accessor :twitter_handle
		mattr_accessor :max_session_inactivity
		mattr_accessor :encryption_secret
		mattr_accessor :registered_user_class
		mattr_accessor :default_user_status
		mattr_accessor :google_analytics_code
		mattr_accessor :google_analytics_site
		mattr_accessor :google_analytics_event_logging
		mattr_accessor :google_analytics_debug
		mattr_accessor :default_protocol
		mattr_accessor :reserved_words
		mattr_accessor :require_email_collector

		self.log_events = true
		self.app_name = 'SwellApp'
		self.app_host = ENV['APP_DOMAIN'] || 'localhost:3000'
		self.asset_host = ENV['ASSET_HOST']
		self.app_description = 'A Very Swell App indeed'
		self.app_logo = 'https://media.licdn.com/media/p/1/000/27f/2a3/36f3707.jpg'
		self.twitter_handle = '@gkparishphilp'
		self.max_session_inactivity = 30.minutes
		self.encryption_secret = 'fdty45u654jtyredhgr4u654etrhdht54eu6e5hdrt5'
		self.registered_user_class = '::User'
		self.default_user_status = 'pending'
		self.google_analytics_code = nil
		self.google_analytics_site = 'localhost'
		self.google_analytics_event_logging = false
		self.google_analytics_debug = false
		self.default_protocol = 'http'
		self.reserved_words = [ 'about', 'aboutus', 'account', 'admin', 'adm1n', 'administer', 'administor', 'administrater', 'administrator', 'anonymous', 'api', 'app', 'apps', 'auth', 'auther', 'author', 'blog', 'blogger', 'cache', 'changelog', 'ceo', 'config', 'contact', 'contact_us', 'contributer', 'contributor', 'cpanel', 'create', 'delete', 'directer', 'director', 'download', 'dowloads', 'edit', 'editer', 'editor', 'email', 'emailus', 'faq', 'favorites', 'feed', 'feeds', 'follow', 'followers', 'following', 'get', 'guest', 'help', 'home', 'hot', 'how_it_works', 'how-ti-works', 'howitworks', 'info', 'invitation', 'invitations', 'invite', 'jobs', 'list', 'lists', 'loggedin', 'loggedout', 'login', 'logout', 'member', 'members', 'moderater', 'moderator', 'mysql', 'new', 'news', 'nobody', 'oauth', 'openid', 'open_id', 'operater', 'operator', 'oracle', 'organizations', 'owner', 'popular', 'porn', 'postmaster', 'president', 'promo', 'promos', 'promotions', 'privacy', 'put', 'registar', 'register', 'registrar', 'remove', 'replies', 'retailer', 'retailers', 'root', 'rss', 'save', 'search', 'security', 'sessions', 'settings', 'signout', 'signup', 'sitemap', 'ssl', 'staff', 'status', 'stories', 'subscribe', 'support', 'terms', 'test', 'tester', 'tour', 'top', 'trending', 'unfollow', 'unsubscribe', 'update', 'url', 'user', 'users', 'vicepresident', 'viagra', 'webmaster', 'widget', 'widgets', 'wiki', 'wishlist', 'xfn', 'xmpp', 'xxx' ]
		self.require_email_collector = false

	end

	# this function maps the vars from your app into your engine
     def self.configure( &block )
        yield self
     end


	class Engine < ::Rails::Engine
		isolate_namespace SwellMedia

		initializer "swell_media.load_helpers" do |app|
			ActionController::Base.send :include, SwellMedia::ApplicationControllerExtensions
		end
		
		config.generators do |g|
			g.test_framework :rspec
			g.fixture_replacement :factory_girl, :dir => 'spec/factories'
		end
		
	end
end
