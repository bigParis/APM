Pod::Spec.new do |s|
  s.name = "ModHookLibrary"
  s.version = "0.0.14"
  s.summary = "A APM of Launch initial hook."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"bigparis"=>"1006599994@qq.com"}
  s.homepage = "https://github.com/bigParis/APM/blob/main/README.md"
  s.description = "https://github.com/bigParis/APM/blob/main/README.md"
  s.screenshots = ["http://downhdlogo.yy.com/hdlogo/6060/60/60/32/2461322170/u2461322170obTmgQ4.png", "http://lxcode.bs2cdn.yy.com/b4f15e01-f0fd-4ef7-a6b2-2283af482f4b.png", "http://lxcode.bs2cdn.yy.com/0b153d83-ef97-4529-8860-aa1f03595d89.png"]
  s.source = { :path => '.' }

  s.ios.deployment_target    = '9.0'
  s.ios.vendored_framework   = 'ios/ModHookLibrary.framework'
end
