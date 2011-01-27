###
### DONT TOUCH THIS FILE!! It was included automatically. Rather run this again: thor ric_addons:copy_files
### @tags: thor, auto, cool, ric_addons
###

# TODO refactor in subdir

module RicAddonsHelper
  
  def okno(bool,opts={})
    bool = !!bool #force to boolean :)
    icon_name = bool ? 'done.png' : 'destroy.png'
    opts[:height] ||= 20
    image_tag("ric_addons/icons/#{icon_name}", opts )
  end
  
end