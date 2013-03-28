# coding: utf-8

module Boom
  class Item
    attr_accessor :list

    def to_alfred_fb_item(opts = {})
      opts[:show_list_title] ||= false
      title = name
      title += " (#{list.name})" if list && opts[:show_list_title]

      opts[:action] ||= "copy"

      autocomplete = "#{list.name} #{name}"
      autocomplete = "#{opts[:query_prefix]} #{autocomplete}" if opts[:query_prefix]

      {
        :uid          => "#{Alfred.bundle_id} #{list.name + ' ' if list}#{name}",
        :title        => title,
        :subtitle     => value,
        :arg          => "#{opts[:action]} #{list.name} #{name}",
        :valid        => "yes",
        :autocomplete => autocomplete
      }
    end
  end
end
