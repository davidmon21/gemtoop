require 'yaml'
require 'gemirbi'

module Gemtoop
    class GemtoopController
        @@config_path = './config.yaml'
        @@configurations = Object

        def self.init
            @@configurations = YAML.load(File.read(@@config_path))
            self.update_conf
        end

        def self.update_conf
            File.open(@@config_path, 'w') do |file|
                file.write(@@configurations.to_yaml)
            end
        end

        def self.verify_function(uri, cert)
            puts "verify function"
            puts cert.public_key.to_s
            puts cert.not_before
            puts cert.not_after
            return true
        end
        

        def self.grab_gemsite(uri, path, port)
            gemc,socket = self._connect(uri, port)
            return self._grab(File.join(uri,path),gemc, socket)
        end

        def self._connect(uri,port)
            gemc = Gemini::GeminiClient.new :verify_function, tofu_path='./tofudb.yaml'
            status, socket = gemc.establish_connection( uri.chomp('/'), port )
            return gemc,socket
        end

        def self._grab( fulluri,gemc, socket)
            content = {}
            content[:header], content[:data] = gemc.send_request("#{fulluri}", socket)
            check = content[:header].split(' ')
            status = check[0].to_i
            data = check[1]
            case status
            when 20..29
                return content
            when 30..31
                return self._grab(data,gemc, socket)
            else
                content[:data] = "ERROR"
            end
            return content
        end

        def self.htmlify(data)
        end

        def self.configurations
            return YAML.load(File.read(@@config_path))
        end
    end
end