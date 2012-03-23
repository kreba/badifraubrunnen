# This is an extension to the standard database.rake (in [rake path]/lib/tasks).
# It allows you to copy contents between two configured databases.
# Taken from http://justbarebones.blogspot.com/2007/10/copy-model-data-between-databases.html

namespace :db do
  desc "Clone the data associated with a model from the production database to the development database.\n\n" +
    " # If the development database contains any data related to the model, it is purged before the copy is made.\n" +
    " # Specify the model class name on the command line as MODEL=X,Y,Z (no spaces)\n" +
    " # Source database as SOURCE=db (production by default)\n" +
    " # Destination database as DESTINATION=db (development by default)\n\n" +
    " # To enable batch mode BATCH=Y (By default, the task queries the user to view the yaml and \n" +
    " # write it to a file (just in case-call me chicken if you wish)\n" +
    " # e.g. rake db:cloneModelData MODEL=User,Account,Post BATCH=Y\n"
  task :cloneModelData => :environment do

    batchmode = ENV['BATCH'] ? ENV['BATCH'] =~ /^y$/i : false
    sourcedb = ENV['SOURCE'] || 'production'
    puts "Connecting to source database '#{sourcedb}'"
    ActiveRecord::Base.establish_connection(sourcedb)

    unless ENV['MODEL']
      print "Please specify the model class name(s) seperated by commas: "
      model_names = $stdin.gets.strip
    else
      model_names = ENV['MODEL'].strip
    end

    data = {}
    model_names.split(/,/).each do |model_name|

      begin
        klass = Kernel.const_get model_name
      rescue
        raise "Hmm unable to get a Class object corresponding to #{model_name}. Check if you specified the correct model name: #{$!}"
      end

      unless klass.superclass == ActiveRecord::Base
        raise "#{model_name}.superclass (#{klass.superclass}) is not ActiveRecord::Base"
      end

      puts "\nCollecting data for Model Class - #{model_name}"

      # Collect all the data from te production database
      data[model_name] = klass.find(:all)
      puts "Found #{data[model_name].length} records in the #{sourcedb} database"

      unless batchmode
        print "\nDo you want to see a yaml dump? [y|N]: "
        if $stdin.gets.strip =~ /^y/i
          puts data[model_name].to_yaml
        end
        print "\nDo you want to direct the yaml dump to a file? [Y|n]: "
        unless $stdin.gets.strip =~ /^n/i
          print "\nPlease specify the file name : "
          File.open($stdin.gets.strip, 'w') do |f|
            f.write data[model_name].to_yaml
          end
        end
      end

    end

    destdb = ENV['DESTINATION'] || 'development'
    puts "\n--------------------------------------\n\nEstablising connection with the '#{destdb}' database\n\n"

    ActiveRecord::Base.establish_connection(destdb)

    puts "Now deleting model related data from the #{destdb} db\n"

    data.keys.each do |model_name|

      klass = Kernel.const_get model_name

      olddata = klass.find(:all)

      puts "\nFound #{olddata.length} #{model_name} records in the #{destdb} database"
      unless batchmode
        print "Do you want to see a yaml dump? [y|N]: "
        if $stdin.gets.strip =~ /^y/i
          puts olddata.to_yaml
        end
      end

      puts "Deleting old data"
      olddata.each {|f| f.destroy}

      puts "Now copying the #{sourcedb} model data into the #{destdb} database"
      print "Copying #{model_name} records: "
      i = 0
      data[model_name].each do |d|
        begin
          print "#{ i+=1}, "

          obj = klass.new d.attributes
          obj.id = d.id
          obj.save!

          #klass.reflect_on_all_associations.each { |a|
          # puts classname + " -> " + a.name.to_s.camelize.singularize + " [label="+a.macro.to_s+"]"
          #}

        rescue
          raise "Error saving model data: #{$!}"
        end
      end
      puts "\nDone copying #{model_name}\n"
    end
    puts "\nDone."

  end
end