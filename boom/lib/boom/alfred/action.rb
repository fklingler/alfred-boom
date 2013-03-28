# coding: utf-8

module Boom
  module Alfred
    class Action
      class << self
        def storage
          Boom.storage
        end

        def save
          storage.save
        end

        def execute(*args)
          method = args.shift
          return send(method, *args) if method
        end

        def create_list(name, item = nil, value = nil)
          lists = (storage.lists << List.new(name))
          storage.lists = lists
          save
          add_item(name, item, value) unless value.nil?
        end

        def delete_list(name)
          List.delete(name)
          save
        end

        def add_item(list, name, value)
          list = List.find(list)
          list.add_item(Item.new(name, value))
          save
        end

        def delete_item(list_name, name)
          list = List.find(list_name)
          list.delete_item(name)
          save
        end

        def open(list_name, item_name)
          list = List.find(list_name)
          if item_name
            item = storage.items.detect { |item| item.name == item_name }
            Platform.open(item)
          else
            list.items.each { |item| Platform.open(item) }
          end
        end

        def copy(list_name, item_name)
          list = List.find(list_name)
          item = list.find_item(item_name)
          puts item.value
        end
      end
    end
  end
end