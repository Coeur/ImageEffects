#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftImageEffects'
  s.version          = '0.2.1'
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

  # ImageEffects+UIVisualEffect.swift has no real use for now, so we ignore it
  s.default_subspecs = 'extensions', 'Accelerate', 'CoreImage'

  s.subspec 'extensions' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+extensions.swift'
    ss.frameworks = 'UIKit'
  end
  
  s.subspec 'Accelerate' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+Accelerate.swift'
    ss.frameworks = 'Accelerate', 'UIKit'
    ss.ios.deployment_target = '8.0'
    ss.tvos.deployment_target = '9.0'
    #ss.watchos.deployment_target = '4.0'
  end
  
  s.subspec 'CoreImage' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+CoreImage.swift'
    ss.frameworks = 'CoreImage', 'UIKit'
  end
  
  # experimental
  s.subspec 'UIVisualEffect' do |ss|
    ss.source_files = 'SwiftImageEffects/ImageEffects+UIVisualEffect.swift'
    ss.frameworks = 'UIKit'
  end
end
