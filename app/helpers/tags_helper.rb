module TagsHelper
  $TAGS_DEFAULT_INCLUDE_ICON = true
  $TAGS_DEFAULT_CSS_CLASS = 'tag'
  
  def render_tag(tag, opts={})
    ret = ''
    opts[:class] = $TAGS_DEFAULT_CSS_CLASS
    ret += icon('tag-orange') if opts.fetch :include_icon, $TAGS_DEFAULT_INCLUDE_ICON
    #str = "#{tag} (#{tag.id})" rescue 'str'
    ret += content_tag(:span, link_to(tag, "/tags/#{tag.id}"), opts) # :class => 'tag')
    return ret
  end
  
  def render_tags(obj,opts={})
    tag_field_name = opts.fetch :tag_field, 'tag'
    obj.tags.map{|tag| render_tag(tag, opts) }.join(' ').html_safe
  end
  
  def get_tagger(tagging,opts={})
    return nil unless tagging.tagger_type && tagging.tagger_id
    case tagging.tagger_type
      when 'User'; return User.find(tagging.tagger_id)
      when 'Tag';  return Tag.find(tagging.tagger_id)
      else ; raise "Unknown TAgger type: #{tagging.tagger_type}"
    end
  end
  
  def render_tagging_tagger(tagging,opts={})
    # Since tagging.tagger doesnt work, but it could be done... if i knew more about polymoprhisms...
    return '-' unless tagging.tagger_type && tagging.tagger_id
    tagger = get_tagger(tagging)
    link_to(get_tagger)
  end
  
  def render_tagging(obj,opts={})
    str = '' 
    str += content_tag(:span, 
      ('[' + icon('tagging')  + 'Tagging ' + link_to("##{obj.id}",obj.tag) + '] ').html_safe ,
      :class => :tagging 
    ) if opts.fetch :include_tagging, true
    str +=  icon('../../icons/models/todo') + 
      link_to(
        obj.taggable, 
        obj.taggable, 
        :class => obj.taggable.class.to_s.downcase + " " + (obj.taggable.done? ? 'done' : 'undone')
      ) 
    str += " (by #{obj.taggable.user})" if opts.fetch :include_ticket_user,true
    str += " (tagged by #{render_tagging_tagger(obj)})" if opts.fetch :include_tagger,false
    content_tag(:span, str.html_safe,  :class => :tagging ).html_safe
  end
  
end