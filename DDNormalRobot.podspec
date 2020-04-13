Pod::Spec.new do |s|
  s.name             = 'DDNormalRobot'
  s.version          = '0.1.0'
  s.summary          = '嘟嘟聊天机器人'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/renyufei8023/DDNormalRobot'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dudu' => '872943400@qq.com' }
  s.source           = { :git => 'https://github.com/renyufei8023/DDNormalRobot.git', :tag => s.version.to_s }
 
  resources = "DDNormalRobot/DDNormalRobot/Resources/*.{png,bundle}"
  s.platform     = :ios, "11.0"
  s.ios.deployment_target = '9.0'
  s.source_files = 'DDNormalRobot/DDNormalRobot/**/*'
  s.dependency 'DDNetworkHelper'
  s.dependency 'Masonry'
  s.dependency 'YYText'
  s.dependency 'QMUIKit'
  s.dependency 'TZImagePickerController'
  s.dependency 'SDWebImage'
  s.dependency 'SocketRocket'
  s.dependency 'YBImageBrowser'
  s.requires_arc = true
end
