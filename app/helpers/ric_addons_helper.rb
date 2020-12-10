###
### DONT TOUCH THIS FILE!! It was included automatically. Rather run this again: thor ric_addons:copy_files
### @tags: thor, auto, cool, ric_addons
###

# TODO refactor in subdir

module RicAddonsHelper
  
  $anonymnous_default_path ||= "/photos/default.png"
  
  def okno(bool,opts={})
    bool = !!bool #force to boolean :)
    icon_name = bool ? 'done.png' : 'destroy.png'
    opts[:height] ||= 20
    image_tag("ric_addons/icons/#{icon_name}", opts )
  end

  # "aaa.png" =>
  # "/aaa.png" => "RAILS_URL/images/aaa.png" # correct, but adds /images
  # "aaa.png" =>  adds
  def photo_real_url(model, opts={})
    image_dir = opts.fetch :image_dir, '/photos/' # contacts
    my_photo_url = model.photo_url.to_s  # send( opts.fetch(:image_method, :photo_url)) # rescue '' # default_model.png
    my_photo_url = "default.png" if my_photo_url == '' #rescue nil # ||= "default.png"    
    #my_photo_url = $anonymnous_default_path if ( my_photo_url.to_s  == '' )
    my_photo_url =  image_dir + my_photo_url unless my_photo_url.match(/^http[s]:\/\/|^\//) # i.e. http://www.faceboo.com/myphoto.jpg or HTTPS as well
    my_photo_url = '/images'    + my_photo_url if my_photo_url.match(/^\//)                      # i.e. /icons/... is local
    my_photo_url 
  end

  
  def render_photo_url(model, opts={})
    model_type = model.class.to_s
    height = opts.fetch( :height, 100 )
    url = photo_real_url(model,opts)
    image_tag(url, :height => height , :alt => "Photo for #{model_type}: '#{model}' URL='#{url}'")
  end
  
end