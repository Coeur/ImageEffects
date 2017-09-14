#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftImageEffects'
  s.version          = '0.1.0'
  s.summary          = 'Swift implementation of UIImageEffects to apply blur and tint effects to an image.'
  s.description      = <<-DESC
This class contains methods to apply blur and tint effects to an image.
SwiftImageEffects is a Swift implementation of https://developer.apple.com/library/content/samplecode/UIImageEffects/.
                       DESC

  s.homepage         = 'https://github.com/coeur/ImageEffects'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cœur' => 'coeur@gmx.fr' }
  s.source           = { :git => 'https://github.com/coeur/ImageEffects.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/adigitalknight'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.6'
  s.watchos.deployment_target = '2.0'

  # ImageEffects+UIKit.swift has no real use for now, so we ignore it
  s.default_subspecs = 'extensions', 'Accelerate', 'CoreImage'

  s.subspec 'extensions' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+extensions.swift'
    ss.frameworks = 'UIKit'
  end
  s.subspec 'Accelerate' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+Accelerate.swift'
    ss.frameworks = 'Accelerate'
  end
  s.subspec 'CoreImage' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+CoreImage.swift'
    ss.frameworks = 'CoreImage'
  end
  s.subspec 'UIKit' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+UIKit.swift'
    ss.frameworks = 'UIKit'
  end
end
