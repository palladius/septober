require 'test_helper'
=begin  

  Test introduced to test tags stuff that Riccardo is imoplementing right now..

=end
class TagsRiccardoTest < ActiveSupport::TestCase
  #def test_should_be_valid
  #  assert Tag.new.valid?
  #end
  
  def test_todo_should_parse_tag_appropriately
    assert_equal ["prova remove them", %w{tag1 tag2 tag3} ], Todo.extract_tags_and_depure("prova @tag1 @tag2 remove them @tag3")
  end
  
end
