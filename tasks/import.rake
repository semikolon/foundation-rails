require 'fileutils'

desc 'Copy the files from a Foundation 6 distribution to vendor/'
task :import6 do
  base = ENV['DIR']
  unless base && File.exist?(base)
    puts 'Could not find Foundation distribution directory'
    exit 1
  end

  FileUtils.rm_r 'vendor'
  FileUtils.mkdir_p 'vendor/assets/javascripts/foundation'
  FileUtils.mkdir_p 'vendor/assets/stylesheets'

  js_files = Dir.entries(File.join(base, 'js')).sort.select do |entry|
    next false if File.directory? File.join(base, 'js', entry)
    /^foundation\..*\.js$/ =~ entry
  end
  # foundation.core must be loaded before the rest of the JS files.
  js_files.delete 'foundation.core.js'
  js_files.unshift 'foundation.core.js'

  File.open 'vendor/assets/javascripts/foundation.js', 'wb' do |f|
    js_files.each do |file|
      f.write "//= require foundation/#{file}\n"
      FileUtils.cp File.join(base, 'js', file),
                   'vendor/assets/javascripts/foundation'
    end
  end

  FileUtils.cp_r File.join(base, 'scss'), 'vendor/assets/stylesheets/'
  FileUtils.mv 'vendor/assets/stylesheets/scss',
               'vendor/assets/stylesheets/foundation'
end
