
require 'ric/colors'
require 'ric/conf'
require 'ric/debug'
require 'ric/files'
require 'ric/debug'
require 'ric/html'
require 'ric/zibaldone'

require 'ruby_classes/arrays'

module Ric
  #include Ric::Colors
  
  def self.ric_help
    puts :TODO
  end
  
end

include Ric::Colors
include Ric::Conf
include Ric::Debug
include Ric::Files

include RubyClasses::Array