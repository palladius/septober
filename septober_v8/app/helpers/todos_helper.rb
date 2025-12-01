module TodosHelper
  #  Priorities  1        2      3       4        5
  PRIORITIES_NAMES = %w{ ZERO very_low low    normal  high     very_high }
  PRIORITIES_COLORS= %w{ ZERO grey     green  black   orange   red       }

  def render_todo_name(todo)
    title = todo.description
    klasses = "todo #{todo.done? ? 'done' : 'undone' }"
    # Simplified for now, removed on_the_spot_edit
    content_tag( (todo.active ? :b : :s) , todo.name , :title => title , :class => klasses )
  end

  def render_where(todo)
    return unless todo.where.present?
    link_to(
      "📍", 
      "http://maps.google.com?q=#{todo.where}",
      { :title => "#{todo.where}", :target => '_blank' }
    ) 
  end

  def render_todo_second_row(todo)
    ret = []
    ret << content_tag(:span, render_where(todo), :class => :where_small) if todo.where.present?
    
    if todo.overdue?
      ret << content_tag(:span, " (OverDue: #{time_ago_in_words(todo.due)})", :class => "text-red-600 font-bold" ) 
    end
    
    # ret << render_editable_project(todo.project) # Simplified
    
    if todo.still_hidden?
      ret << content_tag(:span, " (hide for: #{time_ago_in_words(todo.hide_until) })", :class => :small_hide_until )
    end

    if todo.progress_status.present? && todo.progress_status > 0
      ret << content_tag(:span, " #{todo.progress_status}%", :class => :progress_status_small)
    end

    if todo.description.present?
       ret << content_tag(:span, " 📝", :title => todo.description, :class => :todo_description_snippet)
    end
    
    # ret << render_tags(todo) # TODO: Port tags rendering

    content_tag(:span, ret.join(" ").html_safe, :class => :second_row )
  end

  def priority_name(num)
    PRIORITIES_NAMES[num]
  end

  def render_priority_icon(priority)
    return if priority == 3 # Normal priority, no icon
    # Using emoji for now instead of images to avoid asset pipeline complexity for this quick port
    icon = case priority
           when 1 then "⬇️"
           when 2 then "🔽"
           when 4 then "🔼"
           when 5 then "⬆️"
           end
    content_tag(:span, icon, :title => "Priority ##{priority}: #{priority_name(priority)}")
  end

  def render_todo_icons(todo)
    icons = []
    icons << render_priority_icon(todo.priority)
    icons << "⚠️" if todo.overdue? # Overdue
    icons << link_to("🔗", todo.url, target: "_blank", title: "Website: #{todo.url}") if todo.url.present?
    icons << link_to("🖼️", todo.photo_url, target: "_blank", title: "Picture") if todo.photo_url.present?
    icons << "❤️" if todo.favorite?
    icons << "🙈" if todo.still_hidden? # Hidden
    
    icons.join(' ').html_safe
  end

  def render_priority(todo)
    priority = todo.priority
    prio_name = PRIORITIES_NAMES[priority]
    color = PRIORITIES_COLORS[priority]
    content_tag(:span , "#{prio_name} (#{priority})", :style => "color:#{color}", :class => "priority_#{priority}")
  end

  def render_duetime(todo)
    return '-' unless todo.due
    time_in_words = time_ago_in_words(todo.due)
    explanation = todo.overdue? ? "#{time_in_words} ago" : "in #{time_in_words}"
    
    color = todo.overdue? ? "red" : "green"
    content_tag( :span, explanation , :style => "color: #{color}")
  end
end
