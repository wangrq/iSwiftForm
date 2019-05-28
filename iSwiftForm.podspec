Pod::Spec.new do |s|
  s.name = 'iSwiftForm'
  s.version = '0.0.2'
  s.license = 'MIT'
  s.summary = 'A lightweight framework to build iOS Forms.'
  s.homepage = 'https://github.com/wangrq/iSwiftForm'
  s.authors = { 'Renquan Wang' => 'wangrqt196@gmail.com' }
  s.source = { :git => 'https://github.com/wangrq/iSwiftForm.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.source_files = 'iSwiftForm/Sources/**/*.swift'
  s.resources = 'iSwiftForm/Sources/**/*.xcassets', 'iSwiftForm/Sources/**/*.xib'
  s.requires_arc = true
  s.swift_version = '5.0'
end