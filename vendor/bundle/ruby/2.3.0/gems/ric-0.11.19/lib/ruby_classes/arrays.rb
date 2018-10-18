
module RubyClasses
  module Array
    class Array
      
      def to_s
        "RicArr[ #{self.join(', ') rescue "ErrArr(#{$!})" } ]"
      end
      
      def to_ric
        "Array.toRic Test Gem"
      end
      
    end
  end
end