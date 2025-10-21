#!/usr/bin/env ruby
# Generate Xcode project for DeliveryXOApp
require 'xcodeproj'

puts "🚀 Generating DeliveryXOApp.xcodeproj..."

# Create the project
project = Xcodeproj::Project.new('DeliveryXOApp.xcodeproj')

# Create main target
main_target = project.new_target(:application, 'DeliveryXOApp', :ios, '15.0')

# Create test targets
test_target = project.new_target(:unit_test_bundle, 'DeliveryXOAppTests', :ios, '15.0')
ui_test_target = project.new_target(:ui_test_bundle, 'DeliveryXOAppUITests', :ios, '15.0')

# Set test target dependencies
test_target.add_dependency(main_target)
ui_test_target.add_dependency(main_target)

# Create main group
main_group = project.main_group.new_group('DeliveryXOApp')
main_group.path = 'DeliveryXOApp'

# Create subgroups
models_group = main_group.new_group('Models')
models_group.path = 'Models'

services_group = main_group.new_group('Services')
services_group.path = 'Services'

vc_group = main_group.new_group('ViewControllers')
vc_group.path = 'ViewControllers'

onboarding_group = vc_group.new_group('Onboarding')
onboarding_group.path = 'Onboarding'

management_group = vc_group.new_group('Management')
management_group.path = 'Management'

views_group = main_group.new_group('Views')
views_group.path = 'Views'

utils_group = main_group.new_group('Utils')
utils_group.path = 'Utils'

resources_group = main_group.new_group('Resources')
resources_group.path = 'Resources'

# Test groups
tests_group = project.main_group.new_group('DeliveryXOAppTests')
tests_group.path = 'DeliveryXOAppTests'

ui_tests_group = project.main_group.new_group('DeliveryXOAppUITests')
ui_tests_group.path = 'DeliveryXOAppUITests'

# Helper to add files
def add_file(group, target, path)
  file_ref = group.new_file(path)
  if path.end_with?('.swift')
    target.source_build_phase.add_file_reference(file_ref)
  elsif path.end_with?('.storyboard')
    target.resources_build_phase.add_file_reference(file_ref)
  elsif path.end_with?('.xcassets')
    file_ref.last_known_file_type = 'folder.assetcatalog'
    target.resources_build_phase.add_file_reference(file_ref)
  elsif path.end_with?('.plist')
    file_ref.last_known_file_type = 'text.plist.xml'
  end
  file_ref
end

# Add App lifecycle files
add_file(main_group, main_target, 'DeliveryXOApp/AppDelegate.swift')
add_file(main_group, main_target, 'DeliveryXOApp/SceneDelegate.swift')

# Add Model files
add_file(models_group, main_target, 'DeliveryXOApp/Models/Store.swift')
add_file(models_group, main_target, 'DeliveryXOApp/Models/Location.swift')
add_file(models_group, main_target, 'DeliveryXOApp/Models/OperatingHours.swift')
add_file(models_group, main_target, 'DeliveryXOApp/Models/Menu.swift')
add_file(models_group, main_target, 'DeliveryXOApp/Models/Collection.swift')
add_file(models_group, main_target, 'DeliveryXOApp/Models/Product.swift')

# Add Service files
add_file(services_group, main_target, 'DeliveryXOApp/Services/APIClient.swift')
add_file(services_group, main_target, 'DeliveryXOApp/Services/RestaurantService.swift')
add_file(services_group, main_target, 'DeliveryXOApp/Services/MenuService.swift')
add_file(services_group, main_target, 'DeliveryXOApp/Services/MediaService.swift')

# Add Utils files
add_file(utils_group, main_target, 'DeliveryXOApp/Utils/Constants.swift')

# Add ViewController files
add_file(onboarding_group, main_target, 'DeliveryXOApp/ViewControllers/Onboarding/StoreSetupViewController.swift')
add_file(onboarding_group, main_target, 'DeliveryXOApp/ViewControllers/Onboarding/LocationSetupViewController.swift')
add_file(onboarding_group, main_target, 'DeliveryXOApp/ViewControllers/Onboarding/CollectionSelectionViewController.swift')
add_file(onboarding_group, main_target, 'DeliveryXOApp/ViewControllers/Onboarding/ProductCreationViewController.swift')
add_file(onboarding_group, main_target, 'DeliveryXOApp/ViewControllers/Onboarding/ReviewSubmitViewController.swift')

# Add Resources
add_file(resources_group, main_target, 'DeliveryXOApp/Assets.xcassets')
add_file(resources_group, main_target, 'DeliveryXOApp/LaunchScreen.storyboard')
info_plist = resources_group.new_file('DeliveryXOApp/Info.plist')

# Configure build settings for main target
main_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.deliveryx.oapp'
  config.build_settings['INFOPLIST_FILE'] = 'DeliveryXOApp/Info.plist'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
    '$(inherited)',
    '@executable_path/Frameworks'
  ]
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
end

# Configure build settings for test targets
[test_target, ui_test_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.deliveryx.oapp.#{target.name}"
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(inherited)',
      '@executable_path/Frameworks',
      '@loader_path/Frameworks'
    ]
    config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/DeliveryXOApp.app/$(BUNDLE_EXECUTABLE_PATH)' if target == test_target
  end
end

# Save the project
project.save

puts "✅ Xcode project created successfully!"
puts "📁 Location: DeliveryXOApp.xcodeproj"
puts ""
puts "Next steps:"
puts "1. cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp"
puts "2. pod install"
puts "3. open DeliveryXOApp.xcworkspace"
