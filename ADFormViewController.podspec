Pod::Spec.new do |s|
  s.name				=	'ADFormViewController'
  s.version				=	'1.0.2'
  s.license				=	'MIT'
  s.summary				=	'Create easy table view forms for iOS'
  s.homepage			=	'https://github.com/adamdebono/ADFormViewController'
  s.author				=	{ 'Adam Debono' => 'adam@adebono.com' }
  s.source				=	{ :git => 'https://github.com/adamdebono/ADFormViewController', :tag => '1.0.2' }
  s.platform			=	:ios, '6.0'
  s.source_files		=	['ADFormViewController/*.h', 'ADFormViewController/*.m']
  s.resource_bundles	=	{ 'ADFormViewControllerResources' => ['ADFormViewController/Resources/images/*.png', 'ADFormViewController/Resources/xib/*.xib'] }
  s.requires_arc		=	true
end