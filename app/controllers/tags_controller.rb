class TagsController < ApplicationController
  #include FakeStuff
  
#  1.  copialo da ric_addressbook
#  2.  e a posto RSS  
  def show
    #return unless current_user
    @tag      = current_user ? Tag.find(params[:id]) : ""
    @taggings = current_user ? Tagging.find_all_by_tag_id(params[:id]) : []
  end
  
  def index
    @tags = current_user ? Tag.all : []
  end
  
end

