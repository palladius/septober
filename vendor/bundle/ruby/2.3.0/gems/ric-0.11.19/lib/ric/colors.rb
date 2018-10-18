#!/usr/bin/env ruby
  

  ###################################################################################################################
  # COLORS LIBRARY
=begin
  Somewhere I took this for good terminal colors:
  
    colour_codes = {
            'black':        '\033[0;30m',
            'red':          '\033[0;31m',
            'green':        '\033[0;32m',
            'yellow':       '\033[0;33m',
            'blue':         '\033[0;34m',
            'magenta':      '\033[0;35m',
            'cyan':         '\033[0;36m',
            'white':        '\033[0;37m',
            'darkgray':     '\033[1;30m',
            'br-red':       '\033[1;31m',
            'br-green':     '\033[1;32m',
            'br-yellow':    '\033[1;33m',
            'br-blue':      '\033[1;34m',
            'br-magenta':   '\033[1;35m',
            'br-cyan':      '\033[1;36m',
            'br-white':     '\033[1;37m',
            'ul-black':     '\033[4;30m',
            'ul-red':       '\033[4;31m',
            'ul-green':     '\033[4;32m',
            'ul-yellow':    '\033[4;33m',
            'ul-blue':      '\033[4;34m',
            'ul-magenta':   '\033[4;35m',
            'ul-cyan':      '\033[4;36m',
            'ul-white':     '\033[4;37m',
            'default':      '\033[0m'
    }
=end

module Ric
 module Colors
  $version = 'Ric::Colors::v1.0.5'
  $colors_active = true # DEFAULT: active
  
  $color_db = [
    %w{ normal  black dkblack  red     green brown   blue purple  cyan  lgray   gray     lred    lgreen  yellow lblue violet azure   white  orange   orangey magenta lyellow  pink     gold      orly     heanet  } , # english word
    %w{ normale nero  nerone   rosso   verde marrone blu  porpora ciano grigino grigione rossino verdino giallo lblu  viola  azzurro bianco arancio  arancino magenta giallino rosa     oro      orla     indaco  } , # italian word
    %w{ 0;37    0;30  38;5;236 0;31    1;32  38;5;94 0;34 1;35    0;36  0;37    1;30     1;31    1;32    1;33   1;34  1;35   1;36    1;37   38;5;208 38;5;222 0;35    38;5;229 38;5;203 38;5;214 38;5;214 38;5;93 } ,
    %w{ 000     000   222      f00     0f0           00f  ff0     0ff   aaa     888      f00     afa     ff0                                                                    eebb00 } # HEX RGB
    ]
      # rifallo, e' piu' manutenibile...
  $color_db2 = [
    # [ ARR_COLORS , ]
    %w{ black   nero   0;30     000 },
    %w{ dkblack nerone 38;5;236 222 },
  ]     

  # alias viola = fuxia

  def colors_on
    set_color :on #(true)
  end
  def colors_off
    set_color(false)
  end
  
    # TODO support a block (solo dentro l blocco fai il nocolor)
  def set_color(bool)
    b = bool ? true : false
    deb "Setting color mode to: #{yellow bool} --> #{white b.to_s}"
    b = false if bool.to_s.match( /(off|false)/ )
    deb "Setting color mode to: #{yellow bool} --> #{white b.to_s}"
    $colors_active = bool
  end
  alias :set_colors :set_color

  def bash_color(n, str  )
    "\033[#{n}m#{str}\033[0m"
  end

  def pcolor(color_name='red',str='COLOR: please define a string')
    if $colors_active
      puts colora(color_name,str)
    else
      puts str
    end
  end

  def visible_color(s)
    !( s.match(/nero|black/) )
  end

  def colora(color_name='greenpurpureo',str='colora_test_str2', opts={})
    color_name = color_name.to_s
    return str unless $colors_active
    return str if opts[:nocolor]
    if ix = $color_db[0].index(color_name) 
      bash_color($color_db[2][ix],str)
    elsif ix = $color_db[1].index(color_name)
      bash_color($color_db[2][ix],str)
    else
      debug "Sorry, unknown color '#{color_name}'. Available ones are: #{$color_db[0].join(',') }"
    end
  end

  alias :p :puts

  def color_test(with_italian = false)
    i=0
    palette = $color_db[0].map { |c|
      inglese  = c
      italiano = $color_db[1][i]
      i = i+1
      colora( c, with_italian ? [c,italiano].join(','): c )
    }
    puts( (1..257).map{|c| bash_color( "38;5;#{c}", c) }.join(', ') )
    puts( palette.sort.join(' '))
    _flag_nations.each{|nation|
      puts "- Flag sample: " + flag("ThisIsAFlaggedPhraseBasedOnNation:#{nation}",nation)
    }
  end
  alias :colortest :color_test

  # carattere per carattere...
  def rainbow(str)
    i=0
    ret = '' 
    str=str.to_s
    while(i < str.length)
      ch = str[i]
      palette = $color_db[0][i % $color_db[0].length ]
      ret << (colora(palette,str[i,1]))
      i += 1
    end
    ret
  end
  alias  :arcobaleno :rainbow

  #assert(color_db[0].length == color_db[1].length,"English and italian colors must be the same cardinality!!!")
  # TODO ripeti con , $color_db[1] 
  ( $color_db[0] + $color_db[1] ).each { |colorname|
     dyn_func = "
   
    def get_#{colorname} (str='colors.rb: get_COLOR dynamically generated ENGLISH COLOR ')
      return colora('#{colorname}',str)
    end
  
    def #{colorname} (str='colors.rb: COLOR dynamically generated ENGLISH COLOR TO BE COPIED TO GET')
      return colora('#{colorname}',str) rescue 
         \"Errore #{colorname} con stringa '#"+"{str}' e classe #"+"{str.class} \"
    end
  
    def p#{colorname} (str='colors.rb: pCOLOR dynamically generated ENGLISH COLOR TO BE DESTROYED')
      puts colora('#{colorname}',str)
    end
  
  "
      #debug dyn_func
      eval dyn_func unless method_defined?( "get_#{colorname}".to_sym )
      #remove_method
  }

  def okno(bool,str=nil)
    str ||= bool
    bool = (bool == 0 ) if (bool.class == Fixnum) # so 0 is green, others are red :)
    return bool ? green(str) : red(str)
  end

  def colors_flag(nation = 'it')
    %w{ red white green }
  end

    # "\e[0;31m42\e[0m" --> "42"
    # \e[38;5;28mXXXX    -> "XXX"
  def scolora(str)
    str.to_s.
      gsub(/\e\[1;33m/,''). # colori 16
      gsub(/\e\[0m/,''). # colori 64k
      gsub(/\e\[38;\d+;\d+m/,'') # end color
  end
  alias :uncolor :scolora

    # italia:  green white red
    # ireland: green white orange
    # france:  green white orange
    # UK:      blue white red white blue
    # google:
  def _flag_nations
    %w{cc it de ie fr es en goo br pt}
  end
  def flag(str, flag = '')
    case flag.to_s
      when 'br','pt'
  	      return flag3(str, 'green', 'gold', 'green') 
      when 'cc'
  	           return flag3(str, 'red', 'white', 'red')  # switzerland
      when 'de'
  	           return flag3(str, 'dkblack', 'red',   'gold')
      when 'ie','gd','ga'
  	 return flag3(str, 'green', 'white', 'orange')# non so la differenza, sembrano entrambi gaelici! 
      when 'en'
  	           return flag3(str, 'red', 'blue', 'red') # red white blue white red white blue white ... and again
      when 'es'
  	           return flag3(str, 'yellow', 'red', 'yellow') 
      when 'fr'
  	           return flag3(str, 'blue', 'white', 'red') 
      when 'goo','google'
  	 return flag_n(str, %w{ blue red yellow blue green red } ) 
      when 'it'
             return flag3(str, 'green', 'white', 'red')
      when ''
               return flag3(str + " (missing flag1, try 'it')")
    end
     return flag3(str + " (missing flag2, try 'it')")
  end

    # for simmetry padding
    # m = length / 3
    # 6: 2 2 2        m   m   m    REST 0
    # 5: 2 1 2       m+1  m  m+1        2
    # 4: 1 2 1        m  m+1  m         1
  def flag3(str,left_color='brown',middle_color='pink',right_color='red')
    m = str.length / 3
    remainder = str.length % 3
    central_length = remainder == 1 ? m+1 : m 
    lateral_length = remainder == 2 ? m+1 : m 
    colora(  left_color,    str[ 0 .. lateral_length-1] ) + 
      colora( middle_color, str[ lateral_length .. lateral_length+central_length-1] ) + 
      colora( right_color, str[ lateral_length+central_length .. str.length ] )  
  end

  def flag_n(str,colors)
    size = colors.size
    #debug_on :flag6
    ret = ""
    m = str.length / size # chunk size
    deb m
    (0 .. size-1).each{|i|
      #deb "Passo #{i}"
      chunk = str[m*(i),m*(i+1)]
      #deb chunk
      ret += colora(colors[i], chunk )
    }
    #deb str.split(/....../)
    #remainder = str.length % 6
    return ret + " (bacatino)"
    # central_length = remainder == 1 ? m+1 : m 
    # lateral_length = remainder == 2 ? m+1 : m 
    # colora(  left_color,    str[ 0 .. lateral_length-1] ) + 
    #   colora( middle_color, str[ lateral_length .. lateral_length+central_length-1] ) + 
    #   colora( right_color, str[ lateral_length+central_length .. str.length ] )  
    # return ret
  end



  class RicColor < String
      attr :color
  
      def initialize(mycol)
        super
        @color = mycol
      end
  
      # shouold become context sensitive...
      def to_s
        'RicColor: ' + self.send(@color)
      end
  
      def to_html
        "<font color=\"#{@color}\" >#{self}</font>"
      end
  end #/Class RicColor



    def terminal
      ENV['TERM_PROGRAM'] || 'suppongo_ssh'
    end

    def daltonic_terminal?()
      deb( "Terminal is: " + terminal )
      return !! terminal.to_s.match( /Apple_Terminal/ )
    end

 end # /module Colors
end # /module Ric
