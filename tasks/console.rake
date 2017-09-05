# frozen_string_literal: true

desc 'Run a console with the application loaded'
task :console do
  require 'irb'
  require 'irb/completion'

  require 'app'

  # Load dependencies for easier accessibility through console
  %w[lib services validators].sort.each do |folder|
    Dir[File.join(__dir__, folder, '**', '*.rb')].reverse_each(&method(:require))
  end

  ARGV.clear
  IRB.start
end
