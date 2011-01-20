require 'test_helper'

class TodoTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Todo.new.valid?
  end
end
