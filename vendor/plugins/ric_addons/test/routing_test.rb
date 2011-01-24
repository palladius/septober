# copied from http://izumi.plan99.net/manuals/creating_plugins-8f53e4d6.html

require "#{File.dirname(__FILE__)}/test_helper"
#
#class RoutingTest < Test::Unit::TestCase
#
#  def setup
#    ActionController::Routing::Routes.draw do |map|
#      map.ric_addons
#    end
#  end
#
#  def test_ric_addons_route
#    assert_recognition :get, "/ric_addons", :controller => "ric_addons_controller", :action => "index"
#  end
#
#  private
#
#    # yes, I know about assert_recognizes, but it has proven problematic to
#    # use in these tests, since it uses RouteSet#recognize (which actually
#    # tries to instantiate the controller) and because it uses an awkward
#    # parameter order.
#    def assert_recognition(method, path, options)
#      result = ActionController::Routing::Routes.recognize_path(path, :method => method)
#      assert_equal options, result
#    end
#end
#
#