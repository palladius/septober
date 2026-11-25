# encoding: utf-8
module TodosHelper
  
                #  Priorities  1        2      3       4        5
  $priorities_names = %w{ ZERO very_low low    normal  high     very_high }
  $priorities_colors= %w{ ZERO grey     green  black   orange   red       }
  
  def render_todo_name(todo, opts={} )
    title = [
      todo.description
      ].join("\n")
    klasses = "todo #{todo.done? ? 'done' : 'undone' }"
    coloured_todo = render_within_project(todo.project,on_the_spot_edit(todo, :name, :tooltip => todo.description ) ) rescue "TodoErr('#{$!}')"
    name_content = [render_agent_first_row_icon(todo), coloured_todo].reject(&:blank?).join(' ').html_safe
    ret = content_tag( (todo.active ? :b : :s) , name_content , :title => title , :alt => :alt , :class => klasses ) # , :id => "todo_#{todo.id}")
    return ret
  end
  
  def render_where(todo)
    link_to(
      icon('map') , 
      "http://maps.google.com?q=#{todo.where}",
      {
      :title => "#{todo.where}"
      #:method => :post,
      #:confirm => "Are you sure to go to google map?!?",
      
      },
      :popup => true ,
      :target => '_blank' 
    ) 
    #iconed_link_to('GugolMap', todo.where, "http://maps.google.com/q?#{todo.where}") 
    # , 
  end

  def render_agent_first_row_icon(todo)
    return ''.html_safe unless todo.user && todo.user.agent?
    icon = todo.user.respond_to?(:resolved_agent_icon) ? todo.user.resolved_agent_icon : (todo.user.agent_icon.presence || '🤖')
    host = todo.user.agent_host.presence || 'cloud'
    name = todo.user.username.split('.').last.capitalize
    content_tag(:span, "🤖 #{icon}".html_safe, :class => 'agent_icon_inline', :title => "Autonomous Agent: #{name} on #{host}")
  end

  def render_agent_second_row_badge(todo)
    return ''.html_safe unless todo.user && todo.user.agent?
    icon = todo.user.respond_to?(:resolved_agent_icon) ? todo.user.resolved_agent_icon : (todo.user.agent_icon.presence || '🤖')
    host = todo.user.agent_host.presence || 'cloud'
    name = todo.user.username.split('.').last.capitalize
    content_tag(:span, " [#{icon} #{name} @ #{host}]".html_safe, :class => 'agent_badge_secondary', :title => "Created by agent #{todo.user.username} on #{host}")
  end
  
  # This renders the second line after a todo name in todo Index
  def render_todo_second_row(todo,opts={})
    ret = ''
      # short things
    ret += render_agent_second_row_badge(todo)
    ret += content_tag(:span, render_where(todo), :class => :where_small) if todo.where?
    ret += content_tag(:span, " (OverDue: #{time_ago_in_words(Time.now - todo.due)  rescue todo.due})", :class => :small_overdue ) if todo.overdue?
    ret += render_editable_project(todo.project)
    ret += content_tag(:span, " (hide for: #{time_ago_in_words(todo.hide_until) })", :class => :small_hide_until ) if todo.still_hidden?
    ret += content_tag(:span, " #{on_the_spot_edit(todo, :progress_status)}%".html_safe, :class => :progress_status_small) if todo.progress_status?
      # long
    #ret += content_tag(:span, ' ' + truncate_words(todo.description), :class => :todo_description_snippet)
    ret += content_tag(:span, (' ' + on_the_spot_edit(todo, :description, :type => :textarea, :rows => 4, :tooltip => 'Click to edit description')).html_safe, :class => :todo_description_snippet) 
    ret += render_tags(todo)
    
    #ret.html_safe
    return content_tag(:span, ret.html_safe, :class => :second_row )
  end
  
  ### AAHAHAAHH super! TODO put in ric_addons
  def render_icon_grayable(icon_path, gray, opts={})
    image_tag("#{icon_path}#{gray ? '-grey' : ''}.png", opts)
  end
  
  def render_icon_favorite(todo,opts={})
    render_icon_grayable('icons/todo/favorite', ! todo.favorite, opts.merge(:title => "Favorite is #{todo.favorite}") )
  end
  
  def priority_name(num)
    $priorities_names[num]
  end

  def render_priority_icon(priority,opts={})
    image_tag("icons/priorities/#{priority}.png" , :title => "Priority ##{priority}: #{priority_name(priority)}", :height => 12) unless priority == 3
  end
  
  def eventual_link_priority(todo,raise_or_lower) 
    icon1 = raise_or_lower ? 5 : 1
    icon2 = raise_or_lower ? 4 : 2
    new_priority = raise_or_lower ? todo.priority+1 : todo.priority-1
    exception_priority = raise_or_lower ? 5 : 1
    action = raise_or_lower ? 'raise' : 'lower'
    updown_icon = raise_or_lower ? 'up10x8' : 'down10x8'
    icon_gray = 'white-10x8.png'
    # LOWER/RAISE link
    return link_to( 
      image_tag("icons/priorities/#{updown_icon}-grey.png",
        :mouseover => "icons/priorities/#{updown_icon}.png"  ,
        :height => 8,
        :width => 10
      ),
      "/todos/#{todo.id}/set_priority?new_priority=#{new_priority}", :title => "#{action} priority from #{todo.priority} to #{new_priority}" 
    ) unless todo.priority==exception_priority
    # return gray and NOT linked
    return image_tag("icons/priorities/#{icon_gray}", :width => 10, :height => 8, :title => "Can't #{action} further..")
  end
  
  
  def render_todo_action_icons(todo,opts={})
    cell_height = opts.fetch :cell_height, 40
    border = opts.fetch :border, 0
    icons = []
    ## Priority raise, rtable of 2..
    icons << "<table border='0' ><tr><td width='11' height='16' >" +
        eventual_link_priority(todo, true) +
      #{}"<tr><td >" +
        eventual_link_priority(todo, false)+
      "</table>"
      
    ## Mark as done..
    icons << link_to( 
      image_tag("icons/todo/V-grey.png", :mouseover => "icons/todo/V.png", :height => cell_height) ,
      "/todos/#{todo.id}/done", :title => t(:mark_as_done)
    ) unless todo.done?
    # Formatting the return as a table on its own..
    return ( "<table border=\"#{border}\" ><tr><td height=\"#{cell_height}\" >" + 
      icons.join("</td><td height=\"#{cell_height}\" >") + 
      '</table'
    ).html_safe
  end
  
  def render_todo_icons(todo,opts={})
    icons = []
    height = opts.fetch :height, 12
    icons << render_priority_icon(todo.priority)
    icons << image_tag("icons/todo/overdue.png", :title => 'Overdue!', :height => 12) if todo.overdue?
    icons << link_to(image_tag("ric_addons/icons/website.png", :title => "Website: #{todo.url}", :height => height), todo.url) if todo.url?
    icons << link_to(image_tag("ric_addons/icons/photo_url.png", :title => "Picture: #{todo.photo_url}", :height => height), todo.photo_url) if todo.photo_url?
    icons << image_tag("icons/todo/favorite.png", :title => "You must like this", :height => height) if todo.favorite?
    icons << image_tag("icons/todo/hidden.png", :title => "Hidden Until: #{todo.hide_until}", :height => height) if todo.still_hidden?
    
    # Add more icons here...
    icons.join(' ').html_safe
  end
  
  def render_priority(todo)
    priority = todo.priority
    prio_name = $priorities_names[priority]
    content_tag(:span , "#{prio_name} (#{priority})", :style => "color:"+$priorities_colors[priority], :class => "priority_#{priority}")
  end
  
  def render_todo_hide_until(todo)
    ret = todo.hide_until.to_s || '-' # Time.now
    ret += content_tag(:i, " (#{t :in_the_future_particle} #{time_ago_in_words( todo.hide_until )})") if todo.hide_until
    ret.html_safe
  end
  
  def render_duetime(todo,opts={})
    return '-' unless todo.due
    # TODO: due could NOT exist!
    style_class = "due_explain_#{todo.due_explaination}"
    time_in_words = time_ago_in_words(todo.due.to_time)
    explaination = todo.overdue? ? "#{time_in_words} ago" : "in #{time_in_words}"
    content_tag( :span, explaination , :class => style_class)
  end

  def safe_todo_external_url(raw_url)
    u = raw_url.to_s.strip
    return nil if u.empty?
    return nil if u =~ /\A\s*(javascript|data|vbscript):/i
    u = "https://#{u}" unless u =~ /\Ahttps?:\/\//i
    u
  end

  def render_todo_clickable_url(todo)
    href = safe_todo_external_url(todo.try(:url))
    return nil unless href
    display_url = ERB::Util.html_escape(todo.url.to_s.strip)
    badge = ''
    if href =~ /github\.com\/([^\/]+\/[^\/]+)\/(issues|pull)\/(\d+)/i
      repo = ERB::Util.html_escape($1)
      kind = $2.downcase == 'pull' ? 'PR' : 'Issue'
      num  = ERB::Util.html_escape($3)
      badge = "<span class='todo-url-chip'>GitHub #{kind} ##{num} · #{repo}</span> "
    end
    inner = "#{badge}<span class='todo-url-raw'>#{display_url}</span> <span class='todo-url-arrow'>↗</span>".html_safe
    link_to(inner, href, :target => '_blank', :rel => 'noopener noreferrer', :class => 'todo-url-link')
  end

  def render_todo_show_due(todo)
    return content_tag(:span, 'Nessuna scadenza', :class => 'todo-due-pill is-none') unless todo.due
    today = Date.today
    due_date = (todo.due.to_date rescue nil)
    return content_tag(:span, ERB::Util.html_escape(todo.due.to_s), :class => 'todo-due-pill is-none') unless due_date

    if todo.done?
      was_overdue = (due_date < today)
      suffix = was_overdue ? ' · completato (era scaduto)' : ' · completato'
      return content_tag(:span, "✓ <strong>#{due_date}</strong><span class='todo-due-rel'>#{suffix}</span>".html_safe, :class => 'todo-due-pill is-done')
    end

    diff = (due_date - today).to_i
    if diff < 0
      days_ago = diff.abs
      rel = days_ago == 1 ? 'ieri' : "#{days_ago} giorni fa"
      content_tag(:span, "⚠️ <strong>#{due_date}</strong> <span class='todo-due-rel'>· Scaduto (#{rel})</span>".html_safe, :class => 'todo-due-pill is-overdue')
    elsif diff == 0
      content_tag(:span, "🔥 <strong>#{due_date}</strong> <span class='todo-due-rel'>· Scade OGGI</span>".html_safe, :class => 'todo-due-pill is-today')
    elsif diff <= 2
      rel = diff == 1 ? 'domani' : "tra #{diff} giorni"
      content_tag(:span, "⏰ <strong>#{due_date}</strong> <span class='todo-due-rel'>· #{rel}</span>".html_safe, :class => 'todo-due-pill is-soon')
    else
      content_tag(:span, "📅 <strong>#{due_date}</strong> <span class='todo-due-rel'>· tra #{diff} giorni</span>".html_safe, :class => 'todo-due-pill is-future')
    end
  end

  def format_todo_description_parts(todo)
    raw = todo.try(:description).to_s.strip
    if raw.empty? || raw =~ /\ATranslation missing:\s*en\.quick_created\z/i
      return [nil, nil]
    end

    provenance = nil
    body = raw.dup
    if body.sub!(/\n*\s*(Collected via [^\n]+)\z/m, '')
      provenance = $1.strip
    elsif body.sub!(/\n*\s*(--\s*\nAutoProvisioned[^\z]*)\z/m, '')
      provenance = $1.gsub(/\s+/, ' ').sub(/\A--\s*/, '').strip
    end
    body.strip!

    escaped = ERB::Util.html_escape(body)
    # Auto-link http(s) URLs without swallowing trailing punctuation
    linked = escaped.gsub(/(https?:\/\/[^\s<]+)/) do |match|
      clean = match.sub(/[.,;:!?\)]+\z/, '')
      trail = match[clean.length..-1] || ''
      "<a href=\"#{clean}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"todo-inline-link\">#{clean} ↗</a>#{trail}"
    end

    # Link GHI #N if todo.url points to a GitHub repository
    gh_href = safe_todo_external_url(todo.try(:url))
    if gh_href && gh_href =~ /\A(https?:\/\/github\.com\/[^\/]+\/[^\/]+)/i
      repo_base = $1
      linked = linked.gsub(/\bGHI\s+#(\d+)\b/i) do |m|
        issue_num = $1
        "<a href=\"#{repo_base}/issues/#{issue_num}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"todo-inline-link\">#{m} ↗</a>"
      end
    end

    [linked.empty? ? nil : linked.html_safe, provenance]
  end

  def render_dependency_item(dep_todo, role_label = nil)
    return ''.html_safe unless dep_todo
    is_done = dep_todo.done?
    is_overdue = (!is_done && dep_todo.overdue?)
    status_icon = is_done ? '✓' : '○'
    classes = ['todo-dep-item']
    classes << (is_done ? 'is-done' : 'is-active')
    classes << 'is-overdue' if is_overdue

    inner = ''
    inner << "<span class='todo-dep-status'>#{status_icon}</span>"
    inner << "<span class='todo-dep-role'>#{ERB::Util.html_escape(role_label)}</span>" if role_label
    inner << "<span class='todo-dep-id'>##{dep_todo.id}</span>"
    inner << "<span class='todo-dep-name'>#{ERB::Util.html_escape(dep_todo.name.to_s)}</span>"
    if dep_todo.project
      inner << "<span class='todo-dep-project'>#{ERB::Util.html_escape(dep_todo.project.name.to_s)}</span>"
    end
    if is_overdue && dep_todo.due
      inner << "<span class='todo-dep-overdue'>⚠️ #{dep_todo.due}</span>"
    elsif dep_todo.due && !is_done
      inner << "<span class='todo-dep-due'>📅 #{dep_todo.due}</span>"
    end

    link_to(inner.html_safe, todo_path(dep_todo), :class => classes.join(' '))
  end

end
