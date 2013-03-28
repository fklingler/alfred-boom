# coding: utf-8

module Boom
  module Storage
    class Base
      alias_method :old_initialize, :initialize
      def initialize
        old_initialize
        map_list_to_items
      end

      def map_list_to_items
        @lists.each do |list|
          list.items.each do |item|
            item.list = list
          end
        end
      end
    end
  end
end
