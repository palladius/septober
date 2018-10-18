module Ric
 module Files
   
=begin
   # This tries to implement the xcopy for my git programs
   # similar to xcopy
   
   Originally called 'tra va sa'
=end
   def xcopy(from,to,glob_files, opts={})
     n_actions = 0
     puts "+ Travasing: #{yellow from} ==> #{green to}"
     verbose = opts.fetch :verbose, true
     dryrun  = opts.fetch :dryrun,  true  # i scared of copying files!

     unless File.exists?("#{to}/.git")
       fatal 11,"Sorry cant travase data to an unversioned dir. Please version it with git (or add a .git dir/file to trick me)"
       exit 1
     end
     unless File.exists?("#{to}/.safe_xcopy")
       fatal 12, "Sorry I refuse to xcopy data unless you explicitly ask me to. You have to do this before:\n  #{yellow "touch #{to}/.safe_xcopy"} . 
       You are for sure a very smart person but there are a LOT of people out there who could destroy theyr file system! Thanks"
     end

     # With this i can understand what has been deleted, with lots of magic from git on both ends.. :)
     deb "+ First the differences:"
     deb `diff -qr #{from} #{to} |egrep -v '\\.git' `
     
     puts "Dryrun is: #{azure dryrun}"

     puts "+ Files: #{cyan glob_files}"
     Dir.chdir(from)
     Dir.glob(glob_files).each{ |file|
       from_file = "#{from}/#{file}"
       to_file   = "#{to}/#{file}"
       destdir = File.dirname(to_file)
       deb "Copying: #{yellow from_file}.."
       #  could need creating the dir..
       if File.exists?(destdir)
         # just copy the file
         command = "cp \"#{from_file}\" \"#{to_file}\""
       else
         # mkdir dest AND copy file
         pred "Hey, Dir '#{destdir}' doesnt exist! Creating it.."
         command = "mkdir -p \"#{destdir}\" && cp \"#{from_file}\" \"#{to_file}\""
       end

       if dryrun
         puts "[DRYRUN] Skipping #{gray command}"
       else
         ret =  `#{command} 2>&1`
         puts "EXE: #{gray command}" if verbose
         n_actions += 1
         print( "[ret=$?]", ret, "\n") if (ret.length > 1 || $? != 0) # if output or not zero
       end
     }
     puts "#{n_actions} commands executed."
   end
   
   
 end
end
 