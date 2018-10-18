# random methods i dont know wher eto put right now :(

module Ric
  module Zibaldone
    
    def self.gemdir
      File.dirname( File.dirname(__FILE__) + '/../../..' ) # Im in lib/ric/zibaldone.rb
    end
    
    def self.version
      # TODO memoize/cache this into @@version
      ver = File.read( File.expand_path('VERSION' , gemdir() ) )
      "(v.#{ver})" # for debug
    end
  
    def self.say_hello
      puts "Ric::Zibaldone.say_hello(): This hello is brought to you by ''#{yellow 'Riccardo Carlesso' rescue 'Riccardo Carlesso (Error with color yellow)'}''"
    end
  
    def self.ric_help
      ret = <<-HTML
      == Ric (formerly RicLib) == 
       This is Riccardo library (my first gem!). Try the following commands maybe
      Try some of the following: 
    
        pred    'This is in red'
        pyellow 'This is yellow instead'
    
        gemdir: #{ gemdir }
      HTML
      puts( ret )
      ret
    end
    #alias :help  :ric_help
    #alias :about :ric_help
  
  end #/Zibaldone
end #/Ric