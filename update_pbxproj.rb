require 'xcodeproj'
require 'fileutils'

project_path = 'AlgoBite.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Find the main AlgoBite group
main_group = project.main_group.find_subpath(File.join('AlgoBite'), true)

# Remove AppExtras.swift
old_file = main_group.files.find { |f| f.path == 'AppExtras.swift' }
if old_file
  old_file.remove_from_project
  puts "Removed AppExtras.swift from project"
end

# Create Extras group if it doesn't exist
extras_group = main_group.groups.find { |g| g.name == 'Extras' }
if extras_group.nil?
  extras_group = main_group.new_group('Extras', 'Extras')
  puts "Created Extras group"
end

# Find all split files
Dir.glob('AlgoBite/Extras/*.swift').each do |file|
  filename = File.basename(file)
  # Check if file is already in the group to avoid duplicates
  existing = extras_group.files.find { |f| f.path == filename }
  if existing.nil?
    file_ref = extras_group.new_file(filename)
    target.source_build_phase.add_file_reference(file_ref)
    puts "Added #{filename} to project"
  end
end

project.save
puts "Project saved successfully."
