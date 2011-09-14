require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class Record < Node
      class Attributes < Hash
        def initialize(*args)
          super(*args)
          
          @dimension_value_ids = {}
          @dimension_ids = {}
        end
        
        def dimension_value_id(key)
          @dimension_value_ids[key]
        end
        
        def dimension_id(key)
          @dimension_ids[key]
        end
        
        def dimension_keys
          @dimension_ids.keys
        end
        
        def property_keys
          keys - dimension_keys
        end
        
        def <<(node)
          key = node["Key"]
          self[key] = node.text
          
          if node.name == "AssignedDimensionValue"
            @dimension_value_ids[key] = node["Id"]
            @dimension_ids[key] = node["DimensionId"]
          end
        end
      end
    
      attr_accessor :id, :attributes, :snippets
      
      def initialize(element_or_hash=nil)
        @attributes = Attributes.new
        super(element_or_hash)
      end
      
      def initialize_from_element!
        @id = @element["Id"]
        
        xpath("mdata:Attributes/mdata:AssignedDimensionValue | mdata:Attributes/mdata:Property").each do |attribute|
          @attributes << attribute  
        end
        
        @snippets = property_list("mdata:Snippets/mdata:Snippet")
      end
    end
  end
end
