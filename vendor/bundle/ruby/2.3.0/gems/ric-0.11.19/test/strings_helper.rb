require File.dirname(__FILE__) + '/test_helper'
 
class StringsTest < Test::Unit::TestCase

  def test_to_squawk_prepends_the_word_squawk
     assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
  def test_qwe_is_created_for_string
     assert_equal "worthless method called 'qwe' for 'Hello World'", "Hello World".qwe
  end
  
  def tets_fails
    assert_equal 42,24
  end

end

