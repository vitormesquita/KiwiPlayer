#
# Be sure to run `pod lib lint Malert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QueuePlayer'
  s.version          = '0.1.0'
  s.summary          = 'A cuple of code to help develop a new app'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/vitormesquita/QueuePlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vitor mesquita' => 'vitor.mesquita09@gmail.com' }
  s.source           = { :git => 'https://github.com/vitormesquita/QueuePlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.default_subspec = "/"

  s.subspec "/" do |ss|
    ss.source_files  = "Source/*.swift"
    ss.framework  = "UIKit"
    ss.framework  = "AVFoundation"

  end

end