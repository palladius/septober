module TodosHelper
  
                #  Priorities  1        2      3       4        5
  $priorities_names = %w{ ZERO very_low low    normal  high     very_high }
  $priorities_colors= %w{ ZERO grey     green  black   orange   red       }
  
  # class Priority
  #   @@priorities_names = %w{ ZERO very_low low    normal  high     very_high }
  #   
  #   def new()
  #     
  #   end
  #   
  #   def find
  #     %w{ ZERO very_low low    normal  high     very_high }
  #   end
  #   
  #   def name
  #     :todo
  #   end
  #   
  # end
  
  def render_todo_name(todo, opts={} )
    # (Prio=#{$priorities_names[todo.priority]})
    title = [
      todo.where ? "Where: #{todo.where}" : '-'  ,
      "Due: #{todo.due}",
      "Description: '#{todo.description}'",
      ].join("\n")
    coloured_todo = render_within_project(todo.project,todo.to_s.capitalize) rescue "TodoErr('#{$!}')"
    ret = content_tag( (todo.active ? :b : :s) , coloured_todo , :title => title , :alt => :alt , :class => "todo") # , :id => "todo_#{todo.id}")
    return ret
  end
  
  def render_todo_second_row(todo,opts={})
    ret = ''
    ret += content_tag(:span, "(OverDue: #{time_ago_in_words(Time.now - todo.due)  rescue todo.due})", :class => :small_overdue ) if todo.overdue?
    ret += content_tag(:span, "(hide for: #{time_ago_in_words(todo.hide_until) })", :class => :small_hide_until ) if todo.still_hidden?
    ret += content_tag(:span, truncate_words(todo.description), :class => :description_snippet, :style => 'font-size: xx-small; color: grey')
    ret.html_safe
  end
  
  def priority_name(num)
    $priorities_names[num]
  end

  def render_priority_icon(priority,opts={})
    image_tag("icons/priorities/#{priority}.png" , :title => "Priority ##{priority}: #{priority_name(priority)}", :height => 12)
  end
  
  def eventual_link_priority(todo,raise_or_lower) 
    icon1 = raise_or_lower ? 5 : 1
    icon2 = raise_or_lower ? 4 : 2
    new_priority = raise_or_lower ? todo.priority+1 : todo.priority-1
    exception_priority = raise_or_lower ? 5 : 1
    action = raise_or_lower ? 'raise' : 'lower'
    updown = raise_or_lower ? 'up' : 'down'
    icon_gray = 'white.png'
    # LOWER/RAISE link
    return link_to( 
      image_tag("icons/priorities/#{updown}-grey.png",
        :mouseover => "icons/priorities/#{updown}.png"  ,
        :height => 20
      ),
      "/todos/#{todo.id}/set_priority?new_priority=#{new_priority}", :title => "#{action} priority from #{todo.priority} to #{new_priority}" 
    ) unless todo.priority==exception_priority
    # return gray and NOT linked
    return image_tag("icons/priorities/#{icon_gray}", :height => 20, :title => "Can't #{action} further..")
  end
  
  
  def render_todo_action_icons(todo)
    icons = []
    ## Priority raise
    icons << eventual_link_priority(todo, true)
    icons << eventual_link_priority(todo, false)
    ## Mark as done..
    icons << link_to( 
      image_tag(
        "icons/todo/V-grey.png",
        :mouseover => "icons/todo/V.png"  ,
        :height => 25
      ),
      "/todos/#{todo.id}/done", :title => t(:mark_as_done) 
    ) unless todo.done?
    return icons.join('').html_safe
  end
  
  def render_todo_icons(todo,opts={})
    icons = []
    height = opts.fetch :height, 12
    icons << render_priority_icon(todo.priority)
    icons << image_tag("icons/todo/overdue.png", :title => 'Overdue!', :height => 12) if todo.overdue?
    icons << link_to(image_tag("ric_addons/icons/website.png", :title => "Website: #{todo.url}", :height => height), todo.url) if todo.url?
    icons << image_tag("icons/todo/favorite.png", :title => "You must like this", :height => height) if todo.favorite?
    icons << image_tag("icons/todo/hidden.png", :title => "Hidden Until: #{todo.hide_until}", :height => height) if todo.still_hidden?
    
    # Add more icons here...
    icons.join(' ').html_safe
  end
  
  def render_priority(todo)
    priority = todo.priority
    prio_name = $priorities_names[priority]
    content_tag(:font, "#{prio_name} (#{priority})", :color=>$priorities_colors[priority], :class => "priority_#{priority}")
  end
  

end
