#
# Be sure to run `pod lib lint AGLocationDispatcher.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "AGLocationDispatcher"
    s.version          = "0.0.1"
    s.platform         = :ios, '7.0'
    s.ios.deployment_target = '7.0'
    s.summary          = "Location manage framework working in different modes."
    s.description      = <<-DESC
    This framework provides easy location management with blocks both IOS 7 and IOS 8 !

    * Markdown format.
    * Don't worry about the indent, we strip it!
    DESC
    s.homepage         = "https://github.com/ideas-world/AGLocationDispatcher"
    # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
    s.license          = {:type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Agilie' => 'info@agilie.com' }
    s.source           = { :git => 'https://github.com/ideas-world/AGLocationDispatcher.git',
                            :tag => s.version.to_s
                        }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.requires_arc = true

    s.source_files = 'Pod/Classes/*'
    s.resource_bundles = {
                        'AGLocationDispatcher' => ['Pod/Assets/*.png']
                        }

    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit', 'CoreLocation'
    # s.dependency 'AFNetworking', '~> 2.3'
end

