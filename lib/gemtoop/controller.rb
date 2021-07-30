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
            status,gemc,socket = self._connect(uri, port)
            if status
                if path == '/'
                    path = File.join(uri,path)
                end
                return self._grab(path,gemc, socket)
            else
                return {"data": "connection failed"}
            end
        end

        def self._connect(uri,port)
            gemc = Gemini::GeminiClient.new :verify_function, tofu_path='./tofudb.yaml'
            status, socket = gemc.establish_connection( uri.chomp('/'), port )
            return status,gemc,socket
        end

        def self._grab( fulluri,gemc, socket)
            content = {}
            content[:header], content[:data] = gemc.send_request("#{fulluri}", socket)
            check = content[:header].split(' ')
            status = check[0].to_i
            data = check[1]
            puts fulluri
            case status
            when 20..29
                return content
            when 30..31
                return self._grab(data,gemc, socket)
            else
                puts content[:data]
                puts content[:header]
                content[:data] = "ERROR"
            end
            return content
        end

        def self.htmlify(data)
            new_data = ""
            for line in data
                if line.start_with?("###")
                    line = line.sub!("###","<h3>")
                    line+="</h3><br>"
                    puts line
                elsif line.start_with?("##")
                    line.sub!("##","<h2>")
                    line+="</h2><br>"
                elsif line.start_with?("#")
                    line.sub!("#","<h1>")
                    line+="</h1><br>"
                elsif line.start_with?("=>")
                    pass
                elsif line.start_with?("*")
                end
                new_data+=line
            end
            return new_data
        end

        def self.configurations
            return YAML.load(File.read(@@config_path))
        end
    end
end