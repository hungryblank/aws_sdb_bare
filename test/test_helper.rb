require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'aws_sdb_bare'

class Test::Unit::TestCase

  def assert_attribute(attribute_hash, query_string)
    query_hash = query_hash(query_string)
    attribute_hash.keys.each do |key|
      method = attribute_hash[key].is_a?(Regexp) ? :assert_match : :assert_equal
      send(method, attribute_hash[key], query_hash[key])
    end
  end

  def query_hash(query_string)
    query_hash = query_string.split('&').inject({}) do |hash, token|
      key, value = *token.split('=')
      hash[key] = value
      hash
    end
  end

end
