require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class DimensionValue < Node
      attr_accessor :id, :dimension, :parent, :name, :static_record_count, :values, :properties
      
      def initialize_from_element!
        @id = @element["Id"].to_i
        @name = @element["Name"]
        @is_leaf = @element["IsLeaf"] == "true"
        @is_navigable = @element["IsNavigable"] == "true"
        @static_record_count = @element["StaticRecordCount"].to_i
        
        @values = {}
        xpath("mdata:DimensionValues/mdata:DimensionValue").each do |value|
          dv = DimensionValue.new(value)
          dv.parent = self
          @values[dv.id] = dv
        end
        
        @properties = property_list("mdata:Properties/mdata:Property")
      end
      
      def dimension=(new_dimension)
        @dimension = new_dimension
        values.each do |id, value|
          value.dimension = new_dimension
        end
      end
      
      def leaf?
        @is_leaf
      end
      
      def navigable?
        @is_navigable
      end
      
      def ancestors
        a = parent ? parent.ancestors : []
        a << parent if parent
        a
      end
    end
  end
end
