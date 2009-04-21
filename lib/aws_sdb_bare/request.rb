module AwsSdb

  module Request

    class Base

      HOST = 'sdb.amazonaws.com'

      attr_accessor :account, :secret

      def initialize(method, params, opts={})
        @account = opts[:account] || ENV['AMAZON_ACCESS_KEY_ID']
        @secret = opts[:secret] || ENV['AMAZON_SECRET_ACCESS_KEY']
        @method = method
        @params = params
        add_req_data_to_params
      end

      def host
        HOST
      end

      def path
        '/'
      end

      def uri(protocol = 'http')
        "#{protocol}://" + host + path + '?' + uri_query
      end

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

  end

end

