
module Ric
 module Debug
  # $DEBUG
  $ric_debug_module = 'yes it was loaded'
  
  def debug_on(comment='Debug Activated (some lazy guys didnt provide a description :P)')
    $DEBUG = true
  end
  
  def deb(str)
    puts "#DEB# #{str}" if $DEBUG
  end
  
  # shouldnt work right now yet..
  def debug2(s, opts = {} )
    out = opts.fetch(:out, $stdout)
    tag = opts.fetch(:tag, '_DFLT_')
    really_write = opts.fetch(:really_write, true) # you can prevent ANY debug setting this to false
    write_always = opts.fetch(:write_always, false)
  
    raise "ERROR: ':tags' must be an array in debug(), maybe you meant to use :tag?" if ( opts[:tags] && opts[:tags].class != Array )
    final_str = "#RDeb#{write_always ? '!' : ''}[#{opts[:tag] || '-'}] #{s}"
    final_str = "\033[1;30m" +final_str + "\033[0m" if opts.fetch(:coloured_debug, true) # color by gray by default
    if (debug_tags_enabled? ) # tags
      puts( final_str ) if debug_tag_include?( opts )
    else # normal behaviour: if NOT tag
      puts( final_str ) if ((really_write && $DEBUG) || write_always) && ! opts[:tag]
    end
  end #/debug2() 
  alias :debug :deb
  
=begin

    This is a denbug with steroids

    Introduced tags: NORMAL deb() works.
    If you launch debug_on('reason', :tags => [ :this, :foo, :bar])
    from this moment on normal debug is prevented unless you debug using the explicit tags..

    Il vecchio debug era:
    debug (s, :really_write => true,:write_always => false ) 

=end
  $_debug_tags = []
  def debug_with_steroids(s, opts = {} )
    out = opts.fetch(:out, $stdout)
    tag = opts.fetch(:tag, '_DFLT_')
    really_write = opts.fetch(:really_write, true) # you can prevent ANY debug setting this to false
    write_always = opts.fetch(:write_always, false)

    raise "ERROR: ':tags' must be an array in debug(), maybe you meant to use :tag?" if ( opts[:tags] && opts[:tags].class != Array )
    final_str = "#RDeb#{write_always ? '!' : ''}[#{opts[:tag] || '-'}] #{s}"
    final_str = "\033[1;30m" +final_str + "\033[0m" if opts.fetch(:coloured_debug, true) # color by gray by default
    if (debug_tags_enabled? ) # tags
      puts( final_str ) if debug_tag_include?( opts )
    else # normal behaviour: if NOT tag
      puts( final_str ) if ((really_write && $DEBUG) || write_always) && ! opts[:tag]
    end
  end #/debug()
  def debug_tags_enabled?
    $_debug_tags != []
  end
  def debug_tag_include?(opts)
    assert_array($_debug_tags, 'debug_tags')
    assert_class( opts[:tag], Symbol, "tag must be a symbol, ", :dontdie => true ) if opts[:tag]
    assert_array( opts[:tags] , 'opts[:tags]' ) if opts[:tags]
    return $_debug_tags.include?(opts[:tag].to_sym) if opts[:tag]
    return ($_debug_tags & opts[:tags]).size > 0    if opts[:tags]
    #return $_debug_tags.include?(tag_or_tags.to_sym) if (tag.class == String || tag.class == Symbol)
    return false
  end
  
  # if DEBUG is true, then execute the code
  def deb?() 
  	yield if $DEBUG
  end
  alias :if_deb  :deb?
  alias :if_deb? :deb?

  def debug?()
    $DEBUG == true
  end

  def err(str)
  	$stderr.puts "ERR[RicLib] #{$0}: '#{str}'"
  end

  def fatal(ret,str)
  	err "#{get_red 'RubyFatal'}(#{ret}) #{str}"
  	exit ret
  end

  def warning(s)
  	err "#{yellow 'WARN'} #{s}"
  end
  
  def tbd(comment="TODO")
    puts "#{white :TBD} (#{__FILE__}:#{__LINE__}): #{comment}"
    raise "TBD_EXCEPTION! ''#{comment}''"
  end
  
private
    def _manage_debug_tags(opts)
      $_debug_tags ||= []
      $_debug_tags += opts[:tags] if opts[:tags]
      $_debug_tags = $_debug_tags.uniq
      deb "_manage_debug_tags(): new tags are: #{$_debug_tags}", :tag => :debug
    end

 end # /module Colors
end # /module Ric
