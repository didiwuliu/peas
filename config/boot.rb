require 'rubygems'
require 'bundler/setup'

Bundler.require :default, ENV['RACK_ENV']

Dir["#{Peas.root}/lib/**/*.rb"].each { |f| require f }
Dir["#{Peas.root}/api/**/*.rb"].each { |f| require f }

Mongoid.load!(Peas.root + '/config/mongoid.yml')

module Peas
  class Application < Grape::API

    helpers do
      def logger
        if Peas.environment != 'test'
          Application.logger
        else
          Logger.new("/dev/null")
        end
      end
    end

    rescue_from :all do |e|
      Application.logger.error e
      if Peas.environment == 'development'
        error_response({ message: "#{e.message} @ #{e.backtrace[0]}" })
      end
    end

    format :json
    mount ::Peas::API
    add_swagger_documentation api_version: 'v1'
  end
end
