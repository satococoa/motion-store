unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  app.files += Dir.glob(File.join(app.project_dir, 'lib/motion_store/*.rb'))
  app.frameworks << 'CoreData' unless app.frameworks.include?('CoreData')
  app.files_dependencies 'lib/motion_store/model.rb' => 'lib/motion_store/store.rb'
  app.files_dependencies 'lib/motion_store/store.rb' => 'lib/motion_store/base.rb'
end