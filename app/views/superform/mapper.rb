module Superform
  module Mapper
    class Base
      def initialize(object)
        @object = object
      end

      def get(key)
        raise NotImplementedError
      end

      def key?(key)
        raise NotImplementedError
      end
    end

    class HashMapper < Base
      def key?(key)
        @object.key?(key)
      end

      def get(key)
        @object.fetch key if key? key
      end
    end

    class ObjectMapper < Base
      def get(key)
        @object.send(key) if key? key
      end

      def key?(key)
        @object.respond_to?(key)
      end
    end

    def self.for(object)
      case object
      when Hash
        HashMapper.new(object)
      else
        ObjectMapper.new(object)
      end
    end
  end
end
