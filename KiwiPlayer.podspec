#
# Be sure to run `pod lib lint QueuePlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KiwiPlayer'
  s.version          = '1.0'
  s.summary          = 'Kiwi Player allows you go forward and go back in videos easily! 💃'
  s.homepage         = 'https://github.com/vitormesquita/KiwiPlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vitor mesquita' => 'vitor.mesquita09@gmail.com' }
  s.source           = { :git => 'https://github.com/vitormesquita/KiwiPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'

end