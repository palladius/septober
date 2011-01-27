###
### DONT TOUCH THIS FILE!! It was included automatically. Rather run this again: thor ric_addons:copy_files
### @tags: thor, auto, cool, ric_addons
###
module RiccardoHelper
    # Things I cant live without...
    
  #def auto_table(opts={}) # doesnt work!
      #output_text += "<table border='10'><h1>AutoTable</h1>"
      #yield # if block_given?
      #h "</table>"
  #end
  
  def render_user(u)
    content_tag :span, link_to(u,u), :class => :user
  end
  
  def icon(name,opts={})
    opts[:height] ||= 15
    image_tag("ric_addons/icons/#{name}.png", opts)
  end
  
  def htmlRescueError(theme, err) 
    return "<span class='error'>#{theme}: <font color='red'>#{err}</font></span>".html_safe
  end
  
  def html_strip(html_string)
    html_string.gsub(/<\/?[^>]*>/,  "")
  end
  
    # custom translate, disabled if (opts[:translate] == false)
  def ric_translate(label,opts={})
     opts.fetch(:translate,true) ? t(label,opts) : label 
  end
  
  def iconed_link_to(mylabel, obj, opts={})
    mylabel=mylabel.to_s
    icon_path = opts.fetch(:icon, mylabel.to_s.downcase)
    opts[:title] ||= html_strip(ric_translate(mylabel,opts))
    ret = opts.fetch(:short, false) ? # skip text?
      link_to(icon(icon_path,opts ) , obj, opts) :  # short: just 
      icon(icon_path,opts).html_safe + link_to(ric_translate(mylabel,opts), obj, opts).html_safe # normal, icon + linked obj
    return ret #.html_safe
  end
  
  def iconed_label(mylabel, opts={})
    icon(mylabel.to_s.downcase,opts) + t(mylabel)
  end

  def iconed_content_tag(tag,name, opts={})
    icon = opts.fetch(:icon, name) # defaults to name
    return (content_tag(tag,icon(icon,opts)+' '+name,opts)).html_safe # TODO t(name)
  end
  
  # legal actions: :destroy, :edit
  def iconed_conditional_option_link(action, object)
    return "-" unless can?(action.to_sym,object)
    case action.to_s.downcase
      when 'destroy'
        return iconed_link_to( 'Destroy', object, 
          :confirm => t('Are you sure') + "?", 
          :method => :delete , :short => true
        ) # if can?(:destroy,object)
      when 'edit'
        #return "EDIT TODO"
        return iconed_link_to( 'Edit', edit_polymorphic_path(object), :short => true)
      else # default
        raise "Unknown action: '#{action}' for #{object}!!!"
    end
  end
  
    # TODO put in RicUtil gem !!!
    # always been my dream, to DRY up exception handling! Hahahahah
  def ric_rescue(msg="Unknown Rescue Problem")
    rescue_html = <<-RESCUE_HTML
    <table border='3'>
      <tr>
        <td>
          <img src='/images/photos/palladius-unhappy.jpg' >
        <td >
          <h2 class='debug' ><font color='red'>RicRescue Exception</font>: #{msg}</h2>
      <tr>
        <td>
          Lasterr
        <td  colspan="2" >
          <b>#{$!}</b>
    <tr>
      <td>backtrace
      <td colspan="1" >
        <code class='lilliput' >
        #{ $!.backtrace.first(20).join('<br/>')}
        <br/>
        <br/>
        (These were the first 20 out of #{$!.backtrace.size})
      </code>
    </table>
    RESCUE_HTML
    rescue_html.html_safe # palladius-unhappy.jpg
  end
  
  class Array
    def ids
      map{|element| element.id rescue "IdErr{#{$!}}"}
    end    
  end #/Array
end
