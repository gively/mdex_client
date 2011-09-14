require 'mdex_client/mdata/node'
require 'mdex_client/mdata/dimension_value'

module MDEXClient
  module MData
    class Dimension < Node
      attr_accessor :id, :name, :multi_select, :group_name, :values, :refinements, 
        :parent_id, :selected_value_ids, :implicit_value_ids
      
      def initialize_from_element!
        @id = @element["Id"].to_i
        @name = @element["Name"]
        @multi_select = @element["MultiSelect"]
        @group_name = @element["GroupName"]
        
        @values = {}
        xpath("mdata:DimensionValue").each do |value|
          dv = DimensionValue.new(value)
          dv.dimension = self
          @values[dv.id] = dv
        end
        
        @refinements ||= []
        @selected_value_ids ||= []
        @implicit_value_ids ||= []
      end
      
      def initialize_dimension_state!(element, dimension_values)
        node = Node.new(element)
        refinement_list = node.xpath("mdata:Refinements").first
        if refinement_list
          @parent_id = refinement_list["ParentId"].to_i
          @has_more_refinements = (refinement_list["HasMore"] == "true")
          @is_refinable = (refinement_list["IsRefinable"] == "true")
        end
        
        @refinements = node.dimension_value_state_list("mdata:Refinements", dimension_values)      
        @selected_value_ids = node.dimension_value_state_list("mdata:SelectedDimensionValues", dimension_values)
        @implicit_value_ids = node.dimension_value_state_list("mdata:ImplicitDimensionValues", dimension_values)
      end
      
      def has_more_refinements?
        @has_more_refinements
      end
      
      def refinable?
        @is_refinable
      end
    end
  end
end
