# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aws_sdb_bare}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paolo Negri"]
  s.date = %q{2009-05-14}
  s.email = %q{hungryblank@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["VERSION.yml", "README.rdoc", "lib/aws_sdb_bare.rb", "lib/aws_sdb_bare", "lib/aws_sdb_bare/response.rb", "lib/aws_sdb_bare/request.rb", "test/samples", "test/samples/responses.rb", "test/test_helper.rb", "test/aws_sdb_response_test.rb", "test/aws_sdb_request_test.rb", "test/aws_sdb_request_template_test.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hungryblank/aws_sdb_bare}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
