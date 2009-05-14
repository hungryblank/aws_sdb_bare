require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'samples/responses')

ENV['PARSER'] ||= 'hpricot'

require ENV['PARSER']

class AwsSdbRequestTest < Test::Unit::TestCase

  include AwsSdb

  context "parsing a GetAttributes" do

    should "generate the attributes hash" do
      response = Response.parse(SAMPLE_RESPONSES['GetAttributes'])
      assert_same_elements ["20:45:22", "22:50:25", "22:51:06", "20:44:30", "20:44:19",
      "22:50:55", "22:49:55", "20:30:08", "22:51:02"],  response.attributes['last_visit']
      assert_equal ['62'], response.attributes['code']
    end

  end

  context "parsing a Select" do

    should "generate the items hash" do
      response = Response.parse(SAMPLE_RESPONSES['Select'])
      assert_same_elements ["bar81", "bar83", "bar98", "my_entity5"],  response.items.keys
    end

    should "generate the attributes for each item" do
      response = Response.parse(SAMPLE_RESPONSES['Select'])
      assert_equal({"code" => ["48"], "foo" => ["value"]}, response.items['bar98'])
    end

  end

  context "parsing a Query" do

    should "generate the item names array" do
      response = Response.parse(SAMPLE_RESPONSES['Query'])
      assert_same_elements ["bar81", "bar83", "bar98", "my_entity5"],  response.item_names
    end

  end

  context "parsing a QueryWithAttributes" do

    should "generate the items hash" do
      response = Response.parse(SAMPLE_RESPONSES['QueryWithAttributes'])
      assert_equal({"code" => ["48"], "foo" => ["value"]}, response.items['bar98'])
    end

  end

  context "parsing a response with token" do

    should "find and return the token" do
      response = Response.parse(SAMPLE_RESPONSES['ResWithToken'])
      assert_equal "rO0ABXNyACdjb20uYW1hem9uLnNkcy5RdWVyeVByb2Nlc3Nvci5Nb3JlVG9rZW7racXLnINNqwMA\nCkkAFGluaXRpYWxDb25qdW5jdEluZGV4WgAOaXNQYWdlQm91bmRhcnlKAAxsYXN0RW50aXR5SURa\nAApscnFFbmFibGVkSQAPcXVlcnlDb21wbGV4aXR5SgATcXVlcnlTdHJpbmdDaGVja3N1bUkACnVu\naW9uSW5kZXhaAA11c2VRdWVyeUluZGV4TAASbGFzdEF0dHJpYnV0ZVZhbHVldAASTGphdmEvbGFu\nZy9TdHJpbmc7TAAJc29ydE9yZGVydAAvTGNvbS9hbWF6b24vc2RzL1F1ZXJ5UHJvY2Vzc29yL1F1\nZXJ5JFNvcnRPcmRlcjt4cAAAAAAATZbLYbTOwAAAAAAAAAAAAAArd5WtAAAAAAF0AAI0M35yAC1j\nb20uYW1hem9uLnNkcy5RdWVyeVByb2Nlc3Nvci5RdWVyeSRTb3J0T3JkZXIAAAAAAAAAABIAAHhy\nAA5qYXZhLmxhbmcuRW51bQAAAAAAAAAAEgAAeHB0AAlBU0NFTkRJTkd4", response.token
    end

  end

  context "parsing ListDomains" do

    should "return the list of domains" do
      response = Response.parse(SAMPLE_RESPONSES['ListDomains'])
      assert_same_elements ['myapp_development', 'myapp_production', 'myapp_test', 'test_domain'], response.domains
    end
    %w(ListDomains DomainMetadata)

  end

  context "parsing a request" do

    should "return the metadata" do
      response = Response.parse(SAMPLE_RESPONSES['ListDomains'])
      assert_equal '0.0000071759', response.metadata.box_usage
    end
    %w(ListDomains DomainMetadata)

  end

  context "parsing DomainMetadata" do

    should "provide direct acceess to attributes" do
      response = Response.parse(SAMPLE_RESPONSES['DomainMetadata'])
      assert_equal 282, response.item_count
      assert_equal 7237, response.item_names_size_bytes
      assert_equal 13, response.attribute_name_count
      assert_equal 92, response.attribute_names_size_bytes
      assert_equal 1095, response.attribute_value_count
      assert_equal 5689, response.attribute_values_size_bytes
      assert_equal 1241131496, response.timestamp
    end

  end

  context "parsing simple responses" do

    %w(CreateDomain DeleteDomain PutAttributes BatchPutAttributes DeleteAttributes).each do |simple_request|

      should "recognize #{simple_request}" do
        assert_nothing_raised { Response.parse(SAMPLE_RESPONSES[simple_request]) }
      end

    end

  end

end
