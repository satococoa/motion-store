# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'bundler/setup'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'CoreDataStore'
  app.files += Dir.glob(File.join(app.project_dir, 'lib/store/*.rb'))
  app.frameworks << 'CoreData'
  app.files_dependencies 'lib/store/store_model.rb' => 'lib/store/store.rb'
  app.redgreen_style = :full
end
