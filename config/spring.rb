# My attempt of making spring work with MiniTest::Spec
# THIS IS NO USE since guard is not using it. Maybe I should create a fork on github...

module Spring
  module Commands
    
    class TestUnit < Command
      
      puts '(II) Defining a custom spring command "testspec".'
      
      self.preloads = [
        File.dirname(__FILE__) + '/../spec/minitest_helper'
      ]
            
      def env(*)
        'test'
      end

      def setup
        $LOAD_PATH.unshift 'spec'
        super
      end

      def call(args)
        puts '(II) Using the custom spring command "testspec".'
        
        if args.empty?
          args = ['spec']
        end

        ARGV.replace args
        args.each do |arg|
          path = File.expand_path(arg)
          if File.directory?(path)
            Dir[File.join path, "**", "*_spec.rb"].each { |f| require f }
          else
            require path
          end
        end
      end

      def description
        "Execute a MiniTest::Spec test."
      end
    end
    Spring.register_command "testspec", TestUnit.new

  end 
end
