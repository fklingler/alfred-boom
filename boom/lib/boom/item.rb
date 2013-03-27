# coding: utf-8

module Boom
  class Item
    def to_alfred_fb_item(list)
      {
        :uid          => "#{Alfred.bundle_id}-#{list.name}-#{name}",
        :title        => "#{name}",
        :subtitle     => "#{value}",
        :arg          => "#{url}",
        :valid        => "no",
        :autocomplete => "#{name}"
      }
    end
  end
end
