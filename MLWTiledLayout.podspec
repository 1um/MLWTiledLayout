Pod::Spec.new do |s|
  s.name             = 'MLWTiledLayout'
  s.version          = '0.2.0'
  s.summary          = 'Tiled highly customizable collection view layout'

  s.description      = <<-DESC
`MLWTiledLayout` is `UICollectionViewLayout` subclass that implements tiled layout or
mosaic layout automagically adopted to any iPhone screen size.
Layout is column-based and inspired by lightbox layout.
                       DESC

  s.homepage         = 'https://github.com/ML-Works/MLWTiledLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Podkovyrin' => 'podkovyrin@mlworks.com' }
  s.source           = { :git => 'https://github.com/ML-Works/MLWTiledLayout.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/podkovyr'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MLWTiledLayout/Classes/**/*'

  s.frameworks = 'UIKit'
end
