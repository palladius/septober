module ProjectsHelper
  
  @@colors = %w{ red yellow green magenta cyan blue grey orange }.sort
  @@colors2 = @@colors.map{|c| [c,c] } # TBD in the future translate [['green', 'green'], ['giallo', 'giallo'], ['red', 'rosso2']]   
  
  # on_the_spot_edit @project, :name
  def render_project(project,opts={})
    project_str = project.to_s
    project_str = project_str.upcase + '(!)' if project.public
    opts[:style] = 'font:bold; filter:alpha(opacity=60) '  if project.home_visible
    opts[:style] = 'font-style:italic'  unless project.home_visible
    opts[:title] ||= "(id=#{project.id}) " + project.description
    render_within_project(project,project_str, opts )
  end
  
  # TODO refactor!!!
  def render_within_project(project, str, opts={})
    #opts[:color] = project.color
    opts[:style] = "color:#{project.color}"
    opts[:class] = "project homevisible_#{project.home_visible} public_#{project.public} active_#{project.active}"
    #content_tag(:span, on_the_spot_edit(project, :name) , opts )
    content_tag(:span, str , opts )
  end
  
  # DOESNT WORK!
  # But maybe try this: http://seanbehan.com/programming/yield-a-block-within-rails-helper-method-with-multiple-content_tags-using-concat/
  # yield version to support edit in place!!!
  #def with_project_color_do(project, stuff, opts={})
  #  opts[:style] = "color:#{project.color}"
  #  opts[:class] = "project homevisible_#{project.home_visible} public_#{project.public} active_#{project.active}"
  #  #content_tag(:span, on_the_spot_edit(project, :name) , opts )
  #  raise "I need a block!" unless block_given?
  #  #content_tag(:span, yield , opts )
  #  yield
  #end
  
  def render_editable_project( project )
    #str = on_the_spot_edit( project, :name, :type => :select, :data => Project.owned_by(current_user).all.map{|p| [p.name,p.name]})
    str = project.name
    content_tag(:span, "[#{str}]".html_safe, :class => :project)
  end
  
  def render_editable_color( project)
	  on_the_spot_edit project, :color, :type => :select, :data => @@colors2
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
  
  def render_project_icon(project, opts={})
    #icon = project.photo_url ||  'default.png'
    #image_tag("/images/icons/projects/#{icon}", opts )
    opts[:image_dir] = '/icons/projects/'
    render_photo_url(project, opts)
  end
  
  def render_filter(myfilter,opts={})
    myfilter
  end
end
