require 'mdex_client/client'

module MDEXClient
  module MData
    class Node
      attr_accessor :element
      
      def initialize(element_or_hash=nil)
        return if element_or_hash.nil?
        
        case element_or_hash
        when Nokogiri::XML::Element, Nokogiri::XML::NodeSet
          @element = element_or_hash
          initialize_from_element!
        when Hash
          element_or_hash.each do |key, value|
            send("#{key}=", value)
          end
        else
          raise "Invalid type to initialize a MDEX::MData::Node: #{element_or_hash.class}"
        end
      end
      
      # Subclasses should override this to initialize the appropriate fields from the
      # provided XML element.
      def initialize_from_element!
      end
      
      def css(search)
        @element.css(search, MDEX::Client::NAMESPACES)
      end
      
      def xpath(search)
        @element.xpath(search, MDEX::Client::NAMESPACES)
      end
      
      def record_list(search)
        records = xpath("#{search}/mdata:Record").collect do |child|
          Record.new(child)
        end
        
        xpath("#{search}/mdata:AggregateRecord").each do |child|
          records << AggregateRecord.new(child)
        end
        
        records
      end
      
      def property_list(search)
        xpath(search).inject({}) do |memo, property|
          memo[property["Key"]] = property.text
          memo
        end
      end
      
      def dimension_value_state_list(search, dimension_values)
        query = "#{search}/mdata:DimensionValue | #{search}/mdata:DimensionValueReference"
        xpath(query).collect do |dv|
          dimension_values[dv["Id"].to_i]
        end
      end
    end
  end
end
