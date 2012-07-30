# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'bundler/setup'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionStore'
  app.files += Dir.glob(File.join(app.project_dir, 'lib/motion_store/*.rb'))
  app.frameworks << 'CoreData'
  app.files_dependencies 'lib/motion_store/model.rb' => 'lib/motion_store/store.rb'
  app.files_dependencies 'lib/motion_store/store.rb' => 'lib/motion_store/base.rb'
  app.redgreen_style = :full
end
