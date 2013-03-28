# coding: utf-8

module Boom
  module Alfred
    class Filter
      class << self
        def storage
          Boom.storage
        end

        def execute(*args)
          ::Alfred.with_friendly_error do |alfred|
            Alfred.bundle_id = alfred.bundle_id
            @feedback = alfred.feedback

            query = args.dup

            command = args.shift
            major   = args.shift
            minor   = args.empty? ? nil : args.join(' ')

            delegate(command, major, minor)

            puts @feedback.to_alfred(query)
          end
        end

        def delegate(command, major, minor)

          return overview          unless command
          return all               if command == 'all'
          return edit              if command == 'edit'
          #return switch(major)     if command == 'switch'
          #return show_storage      if command == 'storage'
          #return version           if command == "-v"
          #return version           if command == "--version"
          #return help              if command == 'help'
          #return help              if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
          #return echo(major,minor) if command == 'echo' || command == 'e'
          return open(major,minor) if command == 'open' || command == 'o'
          return random(major)     if command == 'random' || command == 'rand' || command == 'r'

          # if we're operating on a List
          if storage.list_exists?(command)
            return delete_list(command) if major == 'delete'
            return detail_list(command) unless major
            unless minor == 'delete'
              return add_item(command,major,minor) if minor
              return search_list_for_item(command, major)
            end
          end

          if minor == 'delete' and storage.item_exists?(major)
            return delete_item(command, major)
          end

          return search_items(command) unless major

          return create_list(command, major, minor)
        end

        def overview
          storage.lists.each do |list|
            @feedback.add_item(list.to_alfred_fb_item)
          end

          commands = {
            'all'    => 'Display all items',
            'open'   => 'Open URL items in your browser',
            'random' => 'Open a random item',
          }
          commands[:edit] = "Edit JSON file manually" if storage.respond_to?("json_file")
          commands.each do |name,subtitle|
            @feedback.add_item({
              :uid          => "#{Alfred.bundle_id} #{name}",
              :title        => "boom #{name}",
              :subtitle     => subtitle,
              :arg          => "#{name}",
              :valid        => "no",
              :autocomplete => "#{name}"
            })
          end
        end

        def all
          storage.items.each do |item|
            fb_item = item.to_alfred_fb_item(:show_list_title => true)
            @feedback.add_item(fb_item)
          end
        end

        def edit
          if storage.respond_to?("json_file")
            @feedback.add_file_item(storage.json_file)
          end
        end

        def open(major, minor)
          if minor
            list = List.find(major)
            add_feedback_for_search(list.items, minor, :action => 'open', :query_prefix => 'open')
            if @feedback.items.empty?
              @feedback.add_item({
                :title => "No item found",
                :arg   => "",
                :valid => "no",
              })
            end
          else
            add_feedback_for_search(storage.lists, major, :open => true)
            add_feedback_for_search(storage.items, major, :show_list_title => true, :action => 'open', :query_prefix => 'open')
            if @feedback.items.empty?
              @feedback.add_item({
                :title => "No list or item found",
                :arg   => "",
                :valid => "no",
              })
            end
          end
        end

        def random(major)
          if major.nil?
            index = rand(storage.items.size)
            item = storage.items[index]
          elsif storage.list_exists?(major)
            list = List.find(major)
            index = rand(list.items.size)
            item = list.items[index]
          else
            fb_item = {
              :title  => "List #{major} not found",
              :arg    => "",
              :valid  => "no",
            }
          end
          if item
            fb_item = item.to_alfred_fb_item(:action => '')
          else
            fb_item = {
              :title  => "No item found",
              :arg    => "",
              :valid  => "no",
            }
          end
          @feedback.add_item(fb_item)
        end

        def detail_list(name)
          list = List.find(name)
          list.items.sort{ |x,y| x.name <=> y.name }.each do |item|
            fb_item = item.to_alfred_fb_item
            @feedback.add_item(item.to_alfred_fb_item)
          end
          if list.items.empty?
            @feedback.add_item({
              :title        => "No item in list #{name}",
              :arg          => "",
              :valid        => "no",
            })
          end
        end

        def create_list(name, item = nil, value = nil)
          fb_item = {
            :title        => "Create list #{name}",
            :arg          => "create_list #{name}",
          }

          if value
            fb_item[:title] += " and set item #{item}"
            fb_item[:subtitle] = value
            fb_item[:arg] += " #{item} #{value}"
          end

          @feedback.add_item(fb_item)
        end

        def delete_list(name)
          @feedback.add_item({
            :title        => "Delete list #{name}",
            :arg          => "delete_list #{name}",
          })
        end

        def add_item(list, name, value)
          @feedback.add_item({
            :title        => "Create item #{name} in list #{list}",
            :subtitle     => value,
            :arg          => "add_item #{list} #{name} #{value}",
          })
        end

        def delete_item(list_name, name)
          if storage.list_exists?(list_name)
            list = List.find(list_name)
            fb_item = {
              :title  => "Delete item #{name} in list #{list_name}",
              :arg    => "delete_item #{list_name} #{name}",
            }
          else
            fb_item = {
              :title  => "List #{list_name} not found",
              :arg    => "",
              :valid  => "no",
            }
          end
          @feedback.add_item(fb_item)
        end

        def search_items(name)
          add_feedback_for_search(storage.items, name, :show_list_title => true)
          create_list(name)
        end

        def search_list_for_item(list_name, item_name)
          list = List.find(list_name)
          add_feedback_for_search(list.items, item_name)
          if @feedback.items.empty?
            @feedback.add_item({
              :title => "No item found",
              :arg   => "",
              :valid => "no",
            })
          end
        end

        def add_feedback_for_search(search_base, name, opts = {})
          results = []

          results.concat( (search_base - results).select do |result|
            result.name == name
          end)
          results.concat( (search_base - results).select do |result|
            result.name.match(/^#{name}/)
          end)
          results.concat( (search_base - results).select do |result|
            result.name.match(/#{name}/)
          end)

          results.each do |result|
            @feedback.add_item(result.to_alfred_fb_item(opts))
          end
        end
      end
    end
  end
end