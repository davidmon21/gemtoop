require 'active_record'

module Gemtoop
    
    config = Gemtoop::GemtoopController::configurations()
    #ActiveRecord::Base.establish_connection(adapter: config[:adapter], database: config[:db])

end