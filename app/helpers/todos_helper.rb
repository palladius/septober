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
    ret += content_tag(:span, "Due: #{todo.due}", :class => :small_overdue ) if todo.overdue?
    return ret
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
    icon_gray = 'white.png'
    # LOWER/RAISE link
    return link_to( 
      image_tag("icons/priorities/icon_priority#{icon1}.png",
        :mouseover => "icons/priorities/icon_priority#{icon2}.png"  ,
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
    icons << render_priority_icon(todo.priority)
    icons << image_tag("icons/todo/overdue.png", :title => 'Overdue!', :height => 12) if todo.overdue?
    icons << image_tag("icons/todo/overdue.png", :title => 'Overdue!', :height => 12) if todo.overdue?
    
    # Add more icons here...
    icons.join(' ').html_safe
  end
  
  def render_priority(todo)
    priority = todo.priority
    prio_name = $priorities_names[priority]
    content_tag(:font, "#{prio_name} (#{priority})", :color=>$priorities_colors[priority], :class => "priority_#{priority}")
  end
  

end
