#!/usr/bin/env ruby
# Generate Xcode project for DeliveryXOApp

require 'xcodeproj'

# Create the project
project = Xcodeproj::Project.new('DeliveryXOApp.xcodeproj')

# Create main target
target = project.new_target(:application, 'DeliveryXOApp', :ios, '15.0')

# Create app group
app_group = project.main_group.new_group('DeliveryXOApp')
app_group.set_source_tree('<group>')

# Add groups
models_group = app_group.new_group('Models')
services_group = app_group.new_group('Services')
views_group = app_group.new_group('Views')
utils_group = app_group.new_group('Utils')
resources_group = app_group.new_group('Resources')

# Create ViewControllers group with subgroups
vc_group = app_group.new_group('ViewControllers')
onboarding_group = vc_group.new_group('Onboarding')
management_group = vc_group.new_group('Management')

# Add files
def add_file_to_group(project, target, group, file_path)
  file_ref = group.new_file(file_path)
  target.add_file_references([file_ref]) if file_path.end_with?('.swift', '.m', '.mm', '.cpp')
  file_ref
end

# Add AppDelegate and SceneDelegate
add_file_to_group(project, target, app_group, 'DeliveryXOApp/AppDelegate.swift')
add_file_to_group(project, target, app_group, 'DeliveryXOApp/SceneDelegate.swift')

# Add Info.plist
info_plist = resources_group.new_file('DeliveryXOApp/Info.plist')

# Add Assets
assets = resources_group.new_file('DeliveryXOApp/Assets.xcassets')
assets.last_known_file_type = 'folder.assetcatalog'
target.resources_build_phase.add_file_reference(assets)

# Add LaunchScreen
launch_screen = resources_group.new_file('DeliveryXOApp/LaunchScreen.storyboard')
launch_screen.last_known_file_type = 'file.storyboard'
target.resources_build_phase.add_file_reference(launch_screen)

# Set build settings
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.deliveryx.oapp'
  config.build_settings['INFOPLIST_FILE'] = 'DeliveryXOApp/Info.plist'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
end

# Save the project
project.save

puts "✅ Xcode project created successfully!"
puts "📁 Location: DeliveryXOApp.xcodeproj"
