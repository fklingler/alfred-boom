# coding: utf-8

module Boom
  class Alfred
    class << self
      attr_reader :bundle_id

      def storage
        Boom.storage
      end

      def execute(*args)
        ::Alfred.with_friendly_error do |alfred|
          @bundle_id = alfred.bundle_id
          @feedback = alfred.feedback

          command = args.shift
          major   = args.shift
          minor   = args.empty? ? nil : args.join(' ')

          delegate(command, major, minor)

          puts @feedback.to_xml(ARGV)
        end
      end

      def delegate(command, major, minor)
        return overview          unless command
        return all               if command == 'all'
        return edit              if command == 'edit'
        return switch(major)     if command == 'switch'
        return show_storage      if command == 'storage'
        return version           if command == "-v"
        return version           if command == "--version"
        return help              if command == 'help'
        return help              if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
        return echo(major,minor) if command == 'echo' || command == 'e'
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

        return search_items(command) if storage.item_exists?(command) and !major

        return create_list(command, major, minor)
      end

      def overview
        storage.lists.each do |list|
          @feedback.add_item(list.to_alfred_fb_item)
        end
      end
    end
  end
end