
module Rails
  module Helpers
    module RailsHelper

      def anything_to_html(son,opts={})
        ret = '(RailsHelper :: anything_to_html)' if opts.fetch(:verbose,true) # TODO change dflt to false
        if opts != {}
        ret << "(Options: " + anything_to_html(opts) + ")"
        end
        if son.class == Array
          ret << "<ul class='subtopic' >"
          son.each{|subtopic|
            ret << content_tag(:li, anything_to_html(subtopic).html_safe ) # '- ' + 
          }
          ret << "</ul>"
        elsif son.class == Hash
          #ret << hash_to_html(son)
          ret += '<ul class="maintopic" >'
          son.each{ |k,val|
            ret << content_tag(:li, ( anything_to_html(k) + ' => ' + anything_to_html(val) ).html_safe )
           }
          ret << "</ul>"
        elsif son.class == String
          ret << "<font color='navy' class='ricclass_string' >#{son}</font>"
        elsif son.class == Symbol
          ret << "<i><font color='gray' class='ricclass_symbol' >:#{son}</font></i>"
        else
          ret << "(Unknown Class: #{son.class}) <b>#{son}</b>"
        end
        ret.html_safe
      end
  
  end #/RailsHelper
 end
end
