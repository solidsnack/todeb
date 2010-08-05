spec = Gem::Specification.new do |s|
  s.name                     =  'todeb'
  s.version                  =  '0.0.1'
  s.summary                  =  'Automates Debian package production.'
  s.description              =  'Automates Debian package production.'
# s.add_dependency(                                                           )
  s.files                    =  Dir['lib/**/*.rb']
  s.require_path             =  'lib'
  s.bindir                   =  'bin'
  s.executables              =  %w| todeb base16.enc base16.dec |
end

