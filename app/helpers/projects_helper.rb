module ProjectsHelper
  
  def render_project(project)
    #content_tag(:font, project.to_s,  :color => project.color)
    render_within_project(project,project.to_s)
  end
  
  # TODO refactor
  def render_within_project(project, string)
      content_tag(:font, string,  :color => project.color)
  end
end
