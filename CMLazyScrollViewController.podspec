#
# Be sure to run `pod lib lint CMLazyScrollViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CMLazyScrollViewController'
  s.version          = '0.0.2'
  s.summary          = 'Lazy ScrollView with support for infinite scroll (using a paging system with UIViewControllers and not UIViews)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "CMLazyScrollViewController is a controller that I developped in first place to have an infinite carousel of images easily and that i don't have to redo it everytime. And I thought that it would be better than a basic carousel to have UIViewControllers instead of UIViews, to have more complex page. Also I choose to inherit from a UIViewController instead of a UIView because I wanted to be able to add childViewControllers"

  s.homepage         = 'https://github.com/Mycose/CMLazyScrollViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Clément Morissard' => 'morissard@gmail.com' }
  s.source           = { :git => 'https://github.com/Mycose/CMLazyScrollViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CMLazyScrollViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CMLazyScrollViewController' => ['CMLazyScrollViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
