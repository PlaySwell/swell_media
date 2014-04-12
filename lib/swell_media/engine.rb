require 'acts-as-taggable-on'
require 'awesome_nested_set'
require 'cancan'
require 'devise'
require 'friendly_id'
require 'haml'
require 'kaminari'

require 'swell_media/controllers/application_controller_extensions'

module SwellMedia
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
