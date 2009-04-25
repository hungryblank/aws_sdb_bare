module AwsSdb

  module Request

    class Base

      HOST = 'sdb.amazonaws.com'

      attr_accessor :account, :secret

      def initialize(method, params, opts={})
        @account = opts[:account] || ENV['AMAZON_ACCESS_KEY_ID']
        @secret = opts[:secret] || ENV['AMAZON_SECRET_ACCESS_KEY']
        raise <<-end_msg unless @account && @secret
          Amazon AWS account or access key not defined
          Please pass {:account => 'your account', :secret => 'your secret'}
          as a last argument or define the following environment variables
          ENV['AMAZON_ACCESS_KEY_ID']
          ENV['AMAZON_SECRET_ACCESS_KEY']
        end_msg
        @method = method
        @params = params
        add_req_data_to_params
      end

      #Hostname for the request
      def host
        HOST
      end

      #Uri path
      def path
        '/'
      end

      #The full uri for the request, it takes the protocol as argument
      def uri(protocol = 'http')
        "#{protocol}://" + host + path + '?' + uri_query
      end

      #Only the query part of the uri
      def uri_query
        params_query + '&Signature=' + signature
      end

      alias :to_s :uri

      private

      def add_req_data_to_params
        @params.update({'Version' => '2007-11-07',
                        'SignatureVersion' => '2',
                        'SignatureMethod' => 'HmacSHA256',
                        'AWSAccessKeyId' => @account,
                        'Timestamp' => Time.now.gmtime.iso8601})
      end

      def params_query
        @params_query ||= @params.keys.sort.map do |key|
          key + '=' + escape(@params[key].to_s)
        end.join('&')
      end

      def data_to_sign
        [@method, host, path, params_query].join("\n")
      end

      def signature
        @signature ||= begin
          digest = OpenSSL::Digest::Digest.new('sha256')
          hmac = OpenSSL::HMAC.digest(digest, @secret, data_to_sign)
          escape(Base64.encode64(hmac).strip)
        end
      end

      def escape(string)
        URI.escape(string, /[^-_.~a-zA-Z\d]/)
      end

    end

    #Is the parent of all the request templates, defines some methods
    class Template

      class << self

        #Generates method to allow shorter expressions in parameter
        #definition takes an hash
        #
        #  shortcuts({'LongUrlQueryParams' => :abbr})
        #
        #will cause :abbr params to be expanded in LongUrlQueryParams
        def shortcuts(shortcuts_hash)
          shortcuts_hash.each do |full_key, shortcut|
            define_method("#{shortcut}=") do |value|
              @params[full_key] = value
            end
          end
        end

      end

      #takes the params for the request and an optional options hash
      #params for the request are request specific, options accepted are only
      #AWS credentials in form of
      #
      #  {:account => 'your account', :secret => 'your secret'} 
      def initialize(params={}, opts={})
        @params, @opts = params, opts
      end

      def token=(value)
        @params['NextToken'] = value
      end

      def attributes=(attributes)
        attributes.each_with_index do |attribute, index|
          @params["AttributeName.#{index}"] = attribute.to_s
        end
      end

      def request
        expand!
        @request ||= begin
          Base.new('GET', @params.merge('Action' => self.class.to_s.split(':')[-1]), @opts)
        end
      end

      [:to_s, :uri, :uri_query].each do |method|
        define_method(method) do
          request.send(method)
        end
      end

      protected

      def expand!
        @params.keys.each do |key|
          send("#{key}=", @params.delete(key)) if respond_to?("#{key}=")
        end
        @params
      end

    end

    #List the domains
    #
    #  ListDomains.new({:max => 4}, {:account => 'account', :secret => 'secret'})
    #
    #Shortcut in params:
    #
    #  :max - the maximum number of domain that can be returned
    #  :token - the token for follow up requests
    class ListDomains < Template
      shortcuts({'MaxNumberOfDomains' =>  :max})
    end

    #Creates a new domain
    #
    #  CreateDomain.new({:name => 'my_domain'})
    #
    #Shortcut in params:
    #
    #  :name - the name for the new domain
    class CreateDomain < Template
      shortcuts({'DomainName' =>  :name})
    end

    #Deletes a domain
    #
    #  DeleteDomain.new({:name => 'my_domain'})
    #
    #Shortcut in params:
    #
    #  :name - the name for domain
    class DeleteDomain < Template
      shortcuts({'DomainName' =>  :name})
    end

    #Provides informations for a domain
    #
    #  DomainMetadata.new({:name => 'my_domain'})
    #
    #Shortcut in params:
    #
    #  :name - the name for domain
    class DomainMetadata < Template
      shortcuts({'DomainName' =>  :name})
    end

    #Get the attributes for an item
    #
    #  GetAttributes.new({:name => 'my_item', :attributes => [:first, :second]})
    #
    #Shortcut in params:
    #
    #  :name - the item name
    #  :attributes - the list of the attributes to fetch, if not specified
    #                fetches all the attributes
    class GetAttributes < Template
      shortcuts({'ItemName' =>  :name, 'DomainName' => :domain})
    end

    #Add attributes to an item or create a new item whith the given attributes
    #
    #  req = PutAttributes.new({:name => 'my_item'})
    #  req.attributes = {:color => :black, :shape => {:value => :square, :replace => true}}
    #
    #Note: in this request the value 'black' will be added to other color
    #values if they already exist, while the shape value 'square' will replace
    #pre existing values of shape
    #the request, adding the :attributes to the params hash in the new method
    #would have the same effect
    #
    #Note: in the sample above attributes are defined after initializing
    #the request, adding the :attributes to the params hash in the new method
    #would have the same effect
    class PutAttributes < Template

      shortcuts({'ItemName' =>  :name, 'DomainName' => :domain})

      def attributes=(attributes)
        index = 0
        attributes.keys.each do |attr_name|
          replace = nil
          values = case attributes[attr_name]
          when Hash
            replace = attributes[attr_name][:replace].to_s
            attributes[attr_name][:value].to_s
          else
            attributes[attr_name].to_s
          end
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            @params["Attribute.#{index}.Replace"] = replace
            @params["Attribute.#{index}.Name"] = attr_name.to_s
            @params["Attribute.#{index}.Value"] = value
            index += 1
          end
        end
      end

    end

    class BatchPutAttributes < Template

      shortcuts({'DomainName' => :domain})

      private

      def merge_params
        items = []
      end
      
    end

    class DeleteAttributes < Template
      shortcuts({'ItemName' =>  :name, 'DomainName' => :domain})
    end

    class Select < Template
      shortcuts({'SelectExpression' =>  :query})
    end

    class Query < Template
      shortcuts({'DomainName' =>  :domain,
                 'QueryExpression' => :query,
                 'MaxNumberOfItems' => :max})
    end

    class QueryWithAttributes < Template
      shortcuts({'DomainName' =>  :domain,
                 'QueryExpression' => :query,
                 'MaxNumberOfItems' => :max})
    end
  end

end
