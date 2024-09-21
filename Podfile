platform :ios, '14.0'

use_frameworks! # Add this if you are targeting iOS 8+ or using Swift

# ignore all warnings from all pods
inhibit_all_warnings!

target 'TX-EYE' do
  pod 'CocoaAsyncSocket', '~> 7.6.1'
  pod 'SVProgressHUD', '~> 2.1.2'
  pod 'Toast', '~> 3.1.0'
  pod 'Masonry'
  pod 'JSONModel'
#  pod 'SDWebImage', '~> 4.0' # conflict with the one included in MWPhotoBrowser
  pod 'MWPhotoBrowser', :podspec =>'https://raw.githubusercontent.com/FFirX/MWPhotoBrowser/3.1.0/MWPhotoBrowser.podspec'
  pod 'InAppSettingsKit', '~> 2.15'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
