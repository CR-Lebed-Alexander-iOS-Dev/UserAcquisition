Pod::Spec.new do |s|

# 1 - Platform
s.platform = :ios
s.ios.deployment_target = '15.0'
s.name = "UserAcquisition"
s.summary = "iOS library for tracking user acquisition and purchase analytics"
s.description = <<-DESC
UserAcquisition is an iOS library that helps track user acquisition sources and purchase analytics.
It integrates with various attribution platforms like AppsFlyer, Adjust, Branch, and analytics services
like YandexMetrica, Amplitude. Supports both StoreKit 1 and StoreKit 2.
DESC
s.requires_arc = true

# 2 - Version
s.version = "0.4"

# 3 - License
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Author
s.author = { "Alex Lebed" => "al@createx.by" }

# 5 - Homepage
s.homepage = "https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition"

# 6 - Source
s.source = { :git => "https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition",
             :tag => "#{s.version}" }

# 7 - Dependencies
s.static_framework = true
s.dependency 'SwiftyStoreKit'

# 8 - Source Files (правильный путь к файлам)
s.source_files = "UserAcquisition/UserAcquisition/**/*.{h,swift}"
s.public_header_files = "UserAcquisition/UserAcquisition/**/*.h"

# 9 - Framework dependencies
s.frameworks = 'StoreKit', 'AdSupport'

# 10 - Swift Version
s.swift_version = "5"

end