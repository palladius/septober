module ProjectsHelper
  
  def render_project(project,opts={})
    #content_tag(:font, project.to_s,  :color => project.color)
    project_str = project.to_s
    project_str = project_str.upcase + '(!)' if project.public
    opts[:style] = 'font:bold; filter:alpha(opacity=60) '  if project.home_visible
    opts[:style] = 'font-style:italic'  unless project.home_visible
    
    opts[:title] ||= "(id=#{project.id}) " + project.description
    render_within_project(project,project_str, opts )
  end
  
  # TODO refactor
  def render_within_project(project, str, opts={})
    opts[:color] = project.color
    opts[:class] = "project homevisible_#{project.home_visible} public_#{project.public} active_#{project.active}"
    content_tag(:font, str, opts )
  end
  
  # Try this instead: #
  # <span style="background:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;</span>
  
  def render_colored_square(opts={})
    height = opts.fetch(:height, 30)
    width  = opts.fetch(:height, height)
    color  = opts.fetch(:color, :gold )
    
    before= '<span class="colored_square" ><table width="15" height="15" style="border: 1px solid #000">
    <tr><td bgcolor="'+color+'">'
    after = '</td></tr></table></span>'
    if block_given?
      # TODO !
      print "<h1>YIELD</h1>"
      print before
      yield
      print after
    else
      return (before+after).html_safe
    end
    #ret = '<span class="colored_square" ><table width="15" height="15" style="border: 1px solid #000">
    #<tr><td bgcolor="'+color+'"></td></tr>
    #</table></span>'
    #ret .html_safe
  end
end
