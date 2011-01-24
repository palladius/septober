module TodosHelper
  
                #  Priorities  1        2      3       4        5
  $priorities_names = %w{ ZERO very_low low    normal  high     very_high }
  $priorities_colors= %w{ ZERO grey     green  black   orange   red       }
  

  def render_todo_name(todo, opts={} )
    coloured_todo = render_within_project(todo.project,todo.to_s.capitalize) rescue "TodoErr('#{$!}')"
    content_tag( (todo.active ? :i : :s) , coloured_todo , :title => todo.description , :alt => :alt )
    #(todo.active ? "<b>#{coloured_todo}</b>" : "<s>#{coloured_todo}</s>").html_safe
  end
  
  def priority_name(num)
    $priorities_names[num]
  end

  def render_priority_icon(todo,opts={})
    image_tag("icons/priorities/#{todo.priority}.png" )
  end
  
  def render_priority(todo)
    priority = todo.priority
    prio_name = $priorities_names[priority]
    content_tag(:font, "#{prio_name} (#{priority})", :color=>$priorities_colors[priority], :class => "priority_#{priority}")
  end
  

end
