# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Zygo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire'
  pod 'IQKeyboardManagerSwift'
  pod 'Facebook-iOS-SDK', '~> 4.38'
  pod 'FBSDKCoreKit/Swift'
  pod 'FBSDKLoginKit/Swift'
  pod 'GoogleSignIn'
  pod 'XLPagerTabStrip'
  pod 'SDWebImage'
  pod 'RealmSwift'
  pod 'SideMenuSwift'
  pod 'TrueTime'
  pod 'Firebase/Messaging'
  pod 'AlamofireImage', '~> 4.1'
  # Pods for Zygo
  
  pod 'pop', '~> 1.0'
  pod "SimpleAnimation"
  pod 'Branch'
  pod "KlaviyoSwift"
  pod "Firebase/AnalyticsWithoutAdIdSupport"
  pod 'Firebase/Crashlytics'
  
  pod 'Charts'

  post_install do |installer|
      installer.pods_project.targets.each do |target|
        if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
          target.build_configurations.each do |config|
              config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          end
        end
      end
    end
  
end
