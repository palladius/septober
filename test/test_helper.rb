ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def assert_valid(record, comment=nil)
    assert record.valid?, "assert_valid failed: ''#{comment}''\n" + record.errors.full_messages.join("\n")
  end
  
end


class Array
  def to_s
    "TestArray[ #{ join ', ' } ]"
  end
end

class ActiveRecord::Base  
  
  def errorz
    self.errors.full_messages.join( '; ' )
  end
  
  def self.assert_all_valid
    self.find(:all).each do |obj| 
      assert obj.valid? , "AR::#{obj.class} ''#{obj}'' is not valid: #{obj.errors.full_messages.join( ', ' )}"
    end
    
  end
end  