module AwsSdb

  module Response

    MEMBERS = {}

    class UnknownResponse < ArgumentError
    end

    def self.parse(doc)
      @@parser ||= Hpricot if defined?(Hpricot)
      @@parser ||= Nokogiri if defined?(Nokogiri)
      parsed_doc = @@parser.XML(doc)
      begin
        MEMBERS[parsed_doc.root.name].new(parsed_doc)
      rescue
        raise UnknownResponse, "unkwonw response #{doc.inspect}"
      end
    end

    module XmlUtils

      private

      def xml_attr_reader(*attributes)
        attributes.each do |attr|
          define_method(attr.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1]) do
            value = @doc.at(attr).inner_html
            value = yield(value) if block_given?
            value
          end
        end
      end

    end

    class Base
 
      class << self

        def register
          Response::MEMBERS[to_s.split(':').pop + 'Response'] = self 
        end

        def has_items
          define_method :items do
            @items ||= begin
              (@doc / 'Item').inject({}) do |items_hash, item|
                items_hash[item.at('Name').inner_html] = attributes_hash(item)
                items_hash
              end
            end
          end
        end

      end

      def initialize(doc)
        @doc = doc
      end

      def metadata
        @metadata ||= ResponseMetadata.new(@doc.at('ResponseMetadata'))
      end

      def token
        if token_element = @doc.at('NextToken')
          token_element.inner_html
        end
      end

      private

      def attributes_hash(element)
        attr_hash = Hash.new() { |h, k| h[k] = [] }
          (element / 'Attribute').each do |attribute|
            attr_hash[attribute.at('Name').inner_html] << attribute.at('Value').inner_html
          end
        attr_hash
      end

    end

    %w(BatchPutAttributesResponse)

    class GetAttributes < Base

      register

      def attributes
        @attributes ||= attributes_hash(@doc)
      end

    end

    class Select < Base
      register
      has_items
    end

    class QueryWithAttributes < Base
      register
      has_items
    end

    class Query < Base

      register

      def item_names
        @items ||= (@doc / 'ItemName').map { |i| i.inner_html }
      end

    end

    class ListDomains < Base

      register

      def domains
        @domains ||= (@doc / 'DomainName').map { |d| d.inner_html }
      end

    end

    class DomainMetadata < Base

      extend XmlUtils
      register
      xml_attr_reader('ItemCount', 'ItemNamesSizeBytes', 'AttributeNameCount',
                      'AttributeNamesSizeBytes', 'AttributeValueCount',
                      'AttributeValuesSizeBytes', 'Timestamp') { |value| value.to_i }

    end

    %w(CreateDomain DeleteDomain PutAttributes BatchPutAttributes DeleteAttributes).each do |klass|
      module_eval <<-eval_end
        class #{klass} < Base
          register
        end
      eval_end
    end

    class Metadata

      extend XmlUtils

      xml_attr_reader 'RequestId', 'BoxUsage'

      def initialize(doc)
        @doc = doc
      end

    end

  end

end
