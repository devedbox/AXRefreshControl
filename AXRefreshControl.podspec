Pod::Spec.new do |s|

  s.name         = 'AXRefreshControl'
  s.version      = '0.0.5'
  s.summary      = 'A refresh control manager kits.'
  s.description  = <<-DESC
                    A refresh control kits using on iOS platform.
                   DESC

  s.homepage     = 'https://github.com/devedbox/AXRefreshControl'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'aiXing' => '862099730@qq.com' }
  s.platform     = :ios, '7.0'

  s.source       = { :git => 'https://github.com/devedbox/AXRefreshControl.git', :tag => '0.0.5' }
  s.source_files  = 'AXRefreshControl/Classes/*.{h,m}'
  s.public_header_files = 'AXRefreshControl/Classes/AXRefreshControl.h',
                          'AXRefreshControl/Classes/UIScrollView+Refreshable.h'
  s.private_header_files = 'AXRefreshControl/Classes/*_Private.h'
  s.resource  = 'AXRefreshControl/Classes/*.bundle'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AXIndicatorView'
  s.requires_arc = true
end
