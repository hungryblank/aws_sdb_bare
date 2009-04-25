require File.join(File.dirname(__FILE__), 'test_helper')

class AwsSdbRequestTest < Test::Unit::TestCase

  include AwsSdb::Request

  def setup
    ENV['AMAZON_ACCESS_KEY_ID'] = 'a'
    ENV['AMAZON_SECRET_ACCESS_KEY'] = 'a'
  end

  should "prepend the verb and host to the params for signing" do
    req = Base.new('GET', 'Action' => 'ListDomains')
    assert_match /^GET\n#{AwsSdb::Request::Base::HOST}/, req.send(:data_to_sign)
  end

  should "build the query and sort alphabetically the parameters" do
    req = Base.new('GET', 'b' => '2', 'x' => '1', 'a' => '1')
    assert_match /a=1&b=2&x=1/, req.send(:params_query)
  end

  should "url encode the param values" do
    safe_chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_.~"
    some_unsafe_chars = "+*!@£$%^&*()"
    req = Base.new('GET', 'SafeChars' => safe_chars, 'UnsafeChars' => some_unsafe_chars)
    assert_attribute({'SafeChars' => safe_chars}, req.send(:params_query))
    assert_attribute({'UnsafeChars' => '%2B%2A%21%40%C2%A3%24%25%5E%26%2A%28%29'}, req.send(:params_query))
  end

  should "append the signature method to the request" do
    req = Base.new('GET', {'a' => '1'}, {:account => 'account', :secret => 'secret'})
    assert_match /&SignatureMethod=HmacSHA256&SignatureVersion=2/, req.uri_query
  end

  should "add the actual signature" do
    req = Base.new('GET', {'a' => '1'}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Signature' => /^[0-9a-zA-Z%]+$/}, req.uri_query)
  end

  should "build a correct uri" do
    req = Base.new('GET', {'a' => '1'}, {:account => 'account', :secret => 'secret'})
    assert URI.parse(req.uri)
  end

end
