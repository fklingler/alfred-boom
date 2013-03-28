# coding: utf-8

module Boom
  class List
    def to_alfred_fb_item(opts = {})
      arg = opts[:open] ? "open #{name}" : ""
      valid = opts[:open] ? "yes" : "no"
      autocomplete = opts[:open] ? "open #{name}" : name
      {
        :uid          => "#{Alfred.bundle_id} #{name}",
        :title        => name,
        :subtitle     => "",
        :arg          => arg,
        :valid        => valid,
        :autocomplete => autocomplete,
      }
    end
  end
end
