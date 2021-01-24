class PagesController < ApplicationController
  def index
  end

  def docs
  end

  def about
  end

  def search
  end

  def varz
  end

  def varz_testuale
#      render :varz, :plain # :handelrs => :text
#      render :text => "var: 42"
      #https://guides.rubyonrails.org/layouts_and_rendering.html#using-render
      #render :varz, :layout => false
      render file: "#{Rails.root}/app/views/pages/varz.text.erb", :layout => false
  end

end
