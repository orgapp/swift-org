# coding: utf-8
Pod::Spec.new do |s|
  s.name = 'SwiftOrg'
  s.version = '0.7.0'
  s.summary = 'org-mode with swift'
  s.homepage = 'https://github.com/xiaoxinghu/swift-org'
  s.license = { type: 'MIT', file: 'LICENSE' }
  s.author = { 'Xiaoxing Hu' => 'dawnstar.hu@gmail.com' }
  s.social_media_url = 'http://twitter.com/xiaoxinghu'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source = { :git => 'https://github.com/xiaoxinghu/swift-org.git', :tag => "v#{s.version}" }
  s.source_files = 'Sources/**/*.{swift,h}'
end
