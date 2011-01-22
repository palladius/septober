module TodosHelper

  def render_name(todo)
    coloured_todo = render_within_project(todo.project,todo) rescue "TodoErr('#{$!}')"
    (todo.active ? "<b>#{coloured_todo}</b>" : "<s>#{coloured_todo}</s>").html_safe
  end
  
  
  

end
