module ApplicationHelper
  def app_version
    @app_version ||= File.read(Rails.root.join("VERSION")).strip rescue "3.0.0"
  end
end
