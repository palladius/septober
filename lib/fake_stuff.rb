=begin  
  This module was done by Riccardo on a system built with some gems which didnt have those gems anymore :-()


=end

module FakeStuff
  
  def self.included(controller)
    controller.send :helper_method, 
      :can_edit_on_the_spot, 
      :on_the_spot,
      :on_the_spot_edit
  end

  #def can_edit_on_the_spot(*args)
  #  "FakeStuff(): TODO"
  #end
  #
  #def on_the_spot(*args)
  #  "FakeStuff(): on_the_spot"
  #end
  
  #def on_the_spot_edit(*args)
  #  _fake_mock(:on_the_spot_edit, args)
  #end
  
  def method_missing(*args)
    _fake_mock(:method_missing,args)
  end
  
private
  def _fake_mock(funcname,args)
    "FakeStuff::#{funcname}(#{args.map{|x| x.to_s}.join(', ')})"
  end
  


end #/module