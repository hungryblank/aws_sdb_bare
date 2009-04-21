require 'base64'
require 'time'
require 'uri'
require 'openssl'
require 'tagz'
Dir.glob(File.dirname(__FILE__) + '/aws_sdb_bare/**/*.rb').each do |lib|
  require lib
end
