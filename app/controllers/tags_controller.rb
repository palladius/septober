class TagsController < ApplicationController
  include FakeStuff
  
#  1.  copialo da ric_addressbook
#  2.  e a posto RSS  
  def show
    @tag = Tag.find(params[:id]) 
    @taggings =  Tagging.find_all_by_tag_id(params[:id])
  end
  
  def index
    @tags = Tag.all
  end
  
end

