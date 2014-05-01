# My attempt of making guard work with MiniTest::Spec
# THIS IS NO USE since guard is invoked on the shell as a precompiled binary. Makes sense, pity though...

module Guard
  class Minitest
    class Runner
      puts '(II) Overwriting Guard::MiniTest::Runner\'s  spring?()  and  spring_command()  methods.'
      
      def spring?
        puts "(II) Using the new  spring?()  method."
        @options[:spring].is_a?(String) || @options[:spring]
      end
      
      def spring_command(paths)
        puts "(II) Using the new  spring_command()  method."

        spring_cmd = @options[:spring].is_a?(String) ? @options[:spring] : 'testunit'
        cmd_parts = ["spring #{spring_cmd}"]
        cmd_parts << File.expand_path('../runners/old_runner.rb', __FILE__) unless ::MiniTest::Unit::VERSION =~ /^5/

        cmd_parts + relative_paths(paths)
        
        puts "(II) Using command #{cmd_parts.join ' '}"
      end

    end
  end
end