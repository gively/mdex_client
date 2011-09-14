require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class RefinementConfig < Node
      attr_accessor :dimension_value_id, :maximum_dimension_value_count
      attr_writer :expose, :limit_dimension_values, :order_by_record_count
    
      def initialize_from_element!
        @dimension_value_id = @element["DimensionValueId"].to_i
        @expose = (@element["Expose"] == "true")
        @limit_dimension_values = (@element["LimitDimensionValues"] == "true")
        @order_by_record_count = (@element["OrderByRecordCount"] == "true")
        
        if element["MaximumDimensionValueCount"]
          @maximum_dimension_value_count = @element["MaximumDimensionValueCount"].to_i
        end
      end
      
      def expose?
        @expose
      end
      
      def limit_dimension_values?
        @limit_dimension_values
      end
      
      def order_by_record_count?
        @order_by_record_count
      end
      
      def write_xml!(xml)
        attrs = { "DimensionValueId" => dimension_value_id }
        %w(Expose LimitDimensionValues OrderByRecordCount).each do |attribute|
          value = self.send("#{attribute.underscore}?")
          attrs[attribute] = value.to_s unless value.nil?
        end
        attrs["MaximumDimensionValueCount"] = maximum_dimension_value_count unless maximum_dimension_value_count.nil?
        
        xml.mdata :RefinementConfig, attrs
      end
    end
  end
end
