#
# Be sure to run `pod lib lint SoraCrypto.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SoraCrypto'
  s.version          = '0.2.0'
  s.summary          = 'Library contains cryptography related implementation for Sora plaform.'

  s.homepage         = 'https://github.com/soramitsu'
  s.license          = { :type => 'GPL 3.0', :file => 'LICENSE' }
  s.author           = { 'ERussel' => 'emkil.russel@gmail.com' }
  s.source           = { :git => 'https://github.com/soramitsu/crypto-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'VALID_ARCHS' => 'x86_64 armv7 arm64'  }

  s.source_files = 'SoraCrypto/Classes/**/*'

  s.dependency 'IrohaCrypto/Iroha', '~> 0.7.0'
  s.dependency 'SoraDocuments'

  s.test_spec do |st|
      st.source_files = 'Tests/**/*'
  end

end
