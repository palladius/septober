module TodosHelper
  
                #  Priorities  1        2      3       4        5
  $priorities_names = %w{ ZERO very_low low    normal  high     very_high }
  $priorities_colors= %w{ ZERO grey     green  black   orange   red       }
  
  def render_todo_name(todo, opts={} )
    title = "Description: '#{todo.description}'\n (Prio=#{$priorities_names[todo.priority]})\nWhere: #{todo.where}"
    coloured_todo = render_within_project(todo.project,todo.to_s.capitalize) rescue "TodoErr('#{$!}')"
    content_tag( (todo.active ? :i : :s) , coloured_todo , :title => title , :alt => :alt )
    #(todo.active ? "<b>#{coloured_todo}</b>" : "<s>#{coloured_todo}</s>").html_safe
  end
  
  def priority_name(num)
    $priorities_names[num]
  end

  def render_priority_icon(priority,opts={})
    image_tag("icons/priorities/#{priority}.png" , :title => "Priority ##{priority}: #{priority_name(priority)}", :height => 12)
  end
  def render_todo_icons(todo,opts={})
    icons = []
    icons << render_priority_icon(todo.priority)
    icons << image_tag("icons/overdue.png", :title => 'Overdue!', :height => 12) if todo.overdue?
    # Add more icons here...
    icons.join(' ').html_safe
  end
  
  def render_priority(todo)
    priority = todo.priority
    prio_name = $priorities_names[priority]
    content_tag(:font, "#{prio_name} (#{priority})", :color=>$priorities_colors[priority], :class => "priority_#{priority}")
  end
  

end
