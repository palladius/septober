module ProjectsHelper
  
  def render_project(project)
    #content_tag(:font, project.to_s,  :color => project.color)
    render_within_project(project,project.to_s)
  end
  
  # TODO refactor
  def render_within_project(project, string)
      content_tag(:font, string,  :color => project.color)
  end
  
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
