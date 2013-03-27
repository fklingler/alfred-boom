# coding: utf-8

module Boom
  class List
    def to_alfred_fb_item
      {
        :uid          => "#{Alfred.bundle_id}-#{name}",
        :title        => "#{name}",
        :subtitle     => "",
        :arg          => "#{name}",
        :valid        => "no",
        :autocomplete => "#{name}"
      }
    end
  end
end
