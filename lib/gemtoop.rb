require_relative 'gemtoop/version.rb'

module Gemtoop
  require 'sinatra'
  require_relative 'gemtoop/controller.rb'
  require_relative 'gemtoop/model.rb'
  require_relative 'gemtoop/server.rb'
end