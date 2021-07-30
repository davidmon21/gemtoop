require 'yaml'
require 'geminiclient'

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
                    nil
                elsif line.start_with?("*")
                    nil
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