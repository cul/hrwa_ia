
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "blacklight_internet_archive/version"

Gem::Specification.new do |spec|
  spec.name          = "blacklight_internet_archive"
  spec.version       = BlacklightInternetArchive::VERSION
  spec.authors       = ["jd2148"]
  spec.email         = ["jd2148@columbia.edu"]
  spec.summary       = %q{Blacklight discovery interface for an Internet Archive collection.}
  spec.license       = "MIT"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.18', '>= 1.18.0'
  spec.add_development_dependency "blacklight", '~> 6.0'
end
