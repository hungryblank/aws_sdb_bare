require File.join(File.dirname(__FILE__), 'test_helper')

class AwsSdbRequestTemplateTest < Test::Unit::TestCase

  include AwsSdb::Request

  def setup
    ENV['AMAZON_ACCESS_KEY_ID'] = 'a'
    ENV['AMAZON_SECRET_ACCESS_KEY'] = 'a'
  end

  should "add the token using shortcut" do
    req = Template.new({'a' => '1', :token => 'this_is_the_token'})
    assert_attribute({'NextToken' => 'this_is_the_token'}, req.uri_query)
  end

  should "add attributes and number them" do
    req = Template.new({'a' => 1, :attributes => [:attr_1, :attr_2]}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'AttributeName.0' => 'attr_1'}, req.uri_query)
    assert_attribute({'AttributeName.1' => 'attr_2'}, req.uri_query)
  end

  should "generate all the parameters for a ListDomains" do
    req = ListDomains.new({:max => 4}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'ListDomains'}, req.uri_query)
    assert_attribute({'MaxNumberOfDomains' => '4'}, req.uri_query)
  end

  should "generate all the parameters for an CreateDomain" do
    req = CreateDomain.new({:name => 'my_domain'}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'CreateDomain'}, req.uri_query)
    assert_attribute({'DomainName' => 'my_domain'}, req.uri_query)
  end

  should "generate all the parameters for a DeleteDomain" do
    req = DeleteDomain.new({:name => 'my_domain'}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'DeleteDomain'}, req.uri_query)
    assert_attribute({'DomainName' => 'my_domain'}, req.uri_query)
  end

  should "generate all the parameters for a GetAttributes" do
    req = GetAttributes.new({:name => 'my_item', :attributes => [:first, :second]}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'GetAttributes'}, req.uri_query)
    assert_attribute({'ItemName' => 'my_item'}, req.uri_query)
  end

  should "generate all the parameters for a PutAttributes" do
    req = PutAttributes.new({:name => 'my_domain', :name => 'my_item'},
                           {:account => 'account', :secret => 'secret'})
    req.attributes = {:color => :black, :shape => {:value => :square, :replace => true}}
    assert_attribute({'Action' => 'PutAttributes'}, req.uri_query)
    assert_attribute({'ItemName' => 'my_item'}, req.uri_query)
    shape_index = query_hash(req.uri_query)['Attribute.0.Name'] == 'square' ? 0 : 1
    assert_attribute({"Attribute.#{shape_index}.Name" => 'shape'}, req.uri_query)
    assert_attribute({"Attribute.#{shape_index}.Value" => 'square'}, req.uri_query)
    assert_attribute({"Attribute.#{shape_index}.Replace" => 'true'}, req.uri_query)
    color_index = (shape_index - 1).abs
    assert_attribute({"Attribute.#{color_index}.Name" => 'color'}, req.uri_query)
    assert_attribute({"Attribute.#{color_index}.Value" => 'black'}, req.uri_query)
    assert_attribute({"Attribute.#{color_index}.Replace" => nil}, req.uri_query)
  end

  should "generate all the parameters for a Select" do
    req = Select.new({:query => 'Select * from my_domain'}, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'Select'}, req.uri_query)
    assert_attribute({'SelectExpression' => /^Select/}, req.uri_query)
  end

  should "generate all the parameters for a Query" do
    req = Query.new({:query => "['Color' = 'blue']", :domain => 'my_domain', :max => 10 }, {:account => 'account', :secret => 'secret'})
    assert_attribute({'Action' => 'Query'}, req.uri_query)
    assert_attribute({'QueryExpression' => /Color.*blue/}, req.uri_query)
  end

end
