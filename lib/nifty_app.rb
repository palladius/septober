module NiftyApp

=begin  
  # verifies the existance of a file called:
  #conf/nifty_app.yml or 'conf/application.yml'
	#
	#NO, put into ric_addons.yml

    Idea came from a magic metaruby code which allows u to do sth like:
    
    configuration do 
       name :septober
       abstract: lsdalks djalkj dlasjd lkasjl
       email: riccardo@eexample.com       
    end
    
    i found it cool, i know this is different but its cool nonetheless :)
=end
  class Configurer
    attr  :conf
    
      def configurator_parse(opts={})
        conf_file = opts.fetch :conf_file, Rails.root + '/conf/application.yml'
        @conf = YAML.load_file(conf_file)['app']
        puts "Application.yml mapped into @conf: #{green @conf}"
        return @conf
      end      
    
    def method_missing(method,*args)
      @conf ||= configurator_parse()
      return @conf[method.to_s] if @conf[method.to_s]
      return @conf[method.to_sym] if @conf[method.to_sym]
      raise "Key not found in @conf: '#{method}'"
    end
    
  end # class
  
  
  
end
