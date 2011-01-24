class RicAddonsController < ApplicationController
  layout 'ric_addons_app'
  #render_ric_app
  #before_filter :login_required #, :except => [:index, :show]
  
  before_filter :set_subpages
  def set_subpages
    @index_subpages = %w{ about index search test } 
  end
  
  def search
    @query_string = params[:q] || "riccardo"
  end
  
  def index
    #@index_subpages  = %w{ index search tests} 
  end
  
  def about
    
  end
  
  def test
    
  end
  
end