module TodosHelper

  def render_name(todo)
    todo.active ? "<b>todo</b>" : "<i>todo</i>"
  end

end
