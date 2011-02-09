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
  
end