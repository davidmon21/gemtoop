require 'sinatra'
require 'securerandom'
require 'rack/attack'
require 'rack-protection'
module Gemtoop
    class Server < Sinatra::Base
        set :root, Dir.pwd
        configure do
            Gemtoop::GemtoopController::init( )
        end
        session_key = SecureRandom.hex(64)
        enable :sessions
        set :session_secret, session_key
        use Rack::Protection
        use Rack::Attack
        Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
        use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => session_key
        Rack::Attack.safelist('allow from localhost') do |req|
            '127.0.0.1' == req.ip || '::1' == req.ip
        end
        # Rack::Attack.throttle("requests by ip", limit: 4, period: 1) do |request|
        #     if request.path == "/reply" || request.path == "/create_op"
        #         puts request.ip
        #         request.ip
        #     end
        # end
        get '/style.scss' do
            scss :style
        end
        get '/grab_site' do
            pieces = params["fullurl"].split('/')
            baseuri = pieces[0]
            if pieces.length > 1
                path = pieces[1..-1].join('/')
            else
                path = '/'
            end
            more = baseuri.split(':')
            if more.length > 1
                port = more[1].to_i
                baseuri = more[0]
            else
                port = 1965
            end
            puts path
            puts baseuri
            puts port
            content = Gemini::GeminiClient.new(tofu_path='./tofudb.yaml').grab_gemsite(baseuri,path,port)
            @page = Gemtoop::GemtoopController.htmlify content[:data],params["fullurl"]
            #@raw = content[:data]
            erb :index
        end
        get '/' do
            @page = "Visit a site"
            erb :index
        end
    end
end