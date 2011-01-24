
class RicAddons < Thor
  $skel_dir = 'vendor/plugins/ric_addons/skel'
  $thor_ver = '0.9.4b'

  desc :copy_files, "[subdir='**'] Copies files from ric_addons to your local dir [Try subdir='public/**']"
  method_options :help => false
  def copy_files(subdir = '**' , opts={})
    new_ver = File.open('vendor/plugins/ric_addons/VERSION').read rescue "VerErr(#{$!})"
    
    #options[:force] # args as --force
    if options[:help]  # args as --force
      puts "Usage: thor ric:copy_files [subdir]"
      puts "  --help:  this help"
      puts "  --force: force copying (TBIY)"
      puts " Example: thor ric_addons:copy_files 'app/views/**' "
      return -1
    end
    say "RicAddons v.#{new_ver}: Copying a few files from '#{$skel_dir}'…", :yellow
    #puts "RicAddons: injecting files from version: #{new_ver}"
    Dir["#{$skel_dir}/#{subdir}/*"].each do |source|
      destination = source.gsub(/^vendor\/plugins\/ric_addons\/skel\//,'')
      if File.exists?(destination)
        puts "Skipping #{destination} cos it already exists" if opts.fetch(:verbose,false)
      else
        #puts "Generating #{destination}"
        _copy_single_file(source,destination, :lib_ver => new_ver )
      end
    end
  end
  
private
  def _banners(type,opts={})
    common_banner = "
     DONT TOUCH THIS FILE!! It was included automatically. 
     Rather run this again: 'thor ric_addons:copy_files' 
     # Thor Script ver:   #{$thor_ver}
     # RicAddons version: #{opts[:lib_ver]}
     # @tags:             thor, auto, cool, ric_addons
    "
    $banners = {
      :ruby => "=begin\n#{common_banner}\n=end\n",
      :html_erb => "<%\n=begin\n#{common_banner}\n=end\n%>\n"
    }
    return $banners[type.to_sym] # ,"##### Unknown Banner#{}")
  end
  
  def _inject_banner_into_file(type,src,dest,opts={})
    say "Injecting #{dest} with '#{type}' banner.."
    # `(echo -en '#{_banners(type.to_sym,opts)}' ; cat '#{source}' )> '#{destination}'`
    File.open(dest,'w') do |f|
      f.write _banners(type,opts)
      f.write( File.open(src).read )
    end
  end
  
  def _copy_single_file(source,destination, opts={})
    return if File.exists?(destination)
    exists = File.exists?(   destination )
    if File.directory?(source) && ! exists # if dir doesnt exist I create
      say "Creating: #{destination}", :red
      Dir.mkdir(destination) rescue nil
      return 
    end

    if destination.match /(\.rb)$/ # if ruby..
      _inject_banner_into_file(:ruby, source,destination,opts)
    elsif destination.match /(\.html\.erb)$/ # if ruby..
      _inject_banner_into_file(:html_erb,source,destination,opts)
    else
      say( "Copying '#{source}'", :yellow) if opts.fetch(:verbose,true)
      FileUtils.cp(File.expand_path(source),File.expand_path(destination)) rescue "FileCpErr:(#{$!})"
    end
  end

  
end

