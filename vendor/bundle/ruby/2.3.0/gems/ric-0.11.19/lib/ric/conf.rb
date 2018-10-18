module Ric
 module Conf
   
   require 'yaml'

=begin
This wants to be a magic configuration loader who looks for configuration automatically in many places, like:

- ./.CONFNAME.yml
- ~/.CONFNAME.yml
- .CONFNAME/conf.yml

Loads a YAML file looked upon in common places and returns a hash with appropriate values, or an exception 
and maybe a nice explaination..

so you can call load_auto_conf('foo') and it will look throughout any ./.foo.yml,  ~/.foo.yml or even /etc/foo.yml !

=end

   def load_auto_conf(confname, opts={})
     libver = '1.1'
     dirs             = opts.fetch :dirs,          ['.', '~', '/etc/', '/etc/ric/auto_conf/']
     file_patterns    = opts.fetch :file_patterns, [".#{confname}.yml", "#{confname}/conf.yml"]
     sample_hash      = opts.fetch :sample_hash,   { 'load_auto_conf' => "please add an :sample_hash to me" , :anyway => "I'm in #{__FILE__}"}
     verbose          = opts.fetch :verbose,       true
     puts "load_auto_conf('#{confname}') v#{libver} start.." if verbose
     dirs.each{|d|
       dir = File.expand_path(d)
       deb "DIR: #{dir}"
       file_patterns.each{|fp|
             # if YML exists return the load..
         file = "#{dir}/#{fp}"
         deb " - FILE: #{file}"
         if File.exists?(file)
           puts "Found! #{green file}"
           yaml =  YAML.load( File.read(file) )
           puts "load_auto_conf('#{confname}', v#{libver}) found: #{green yaml}"  if verbose
           return yaml # in the future u can have a host based autoconf! Yay!
         end
       }
     }
     puts "Conf not found. Try this:\n---------------------------\n$ cat > ~/#{file_patterns.first}\n#{yellow "#Creatd by ric.rb:load_auto_conf()\n" +sample_hash.to_yaml}\n---------------------------\n"
     raise "LoadAutoConf: configuration not found for '#{confname}'!"
     return sample_hash
   end

   
 end
end