require 'mdex_client/mdata/node'
require 'mdex_client/mdata/dimension'
require 'mdex_client/mdata/refinement_config'
require 'mdex_client/mdata/record'
require 'mdex_client/mdata/aggregate_record'

module MDEXClient
  module MData
    class NavigationResult < Node
      attr_accessor :dimensions, :dimension_values, :refinement_configs, :offset, 
        :records_per_page, :total_record_count,
        :total_aggregate_record_count, :records, :eql_expression, 
        :range_filters, :record_filter, :search_reports, :selected_dimension_value_ids,
        :language_id, :business_rules, :keyword_redirects, :analytics
      
      def initialize_from_element!
        @dimensions = {}
        @dimension_values = {}
        xpath("mdata:Dimensions/mdata:Dimension").each do |child|
          dim = Dimension.new(child)
          @dimensions[dim.id.to_i] = dim
          add_dimension_values!(dim.values)
        end
        
        xpath("mdata:NavigationStatesResult/mdata:DimensionStates/mdata:DimensionState").each do |child|
          dim = @dimensions[child["DimensionId"].to_i]
          dim.initialize_dimension_state!(child, @dimension_values)
        end
                
        refinement_configs = xpath("mdata:NavigationStatesResult/mdata:RefinementConfigs").first
        @expose_all_refinements = (refinement_configs["ExposeAllRefinements"] == "true") if refinement_configs
        @refinement_configs = xpath("mdata:NavigationStatesResult/mdata:RefinementConfigs/mdata:RefinementConfig").collect do |child|
          RefinementConfig.new(child)
        end
        
        records_result = xpath("mdata:RecordsResult").first
        
        @offset = records_result["Offset"].to_i
        @records_per_page = records_result["RecordsPerPage"].to_i
        @total_record_count = records_result["TotalRecordCount"].to_i
        @total_aggregate_record_count = records_result["TotalAggregateRecordCount"].to_i
        @records = record_list("mdata:RecordsResult/mdata:Records")
        
        applied_filters = xpath("mdata:NavigationAppliedFilters")
        if applied_filters.count > 0
          af = Node.new(applied_filters.first)
          @eql_expression = af.xpath("mdata:EqlExpression").text
          @record_filter = af.xpath("mdata:RecordFilter").text
          #TODO: search reports
          @selected_dimension_value_ids = af.xpath("mdata:SelectedDimensionValueIds/mdata:DimensionValueId").collect(&:to_i)
          @language_id = af.xpath("mdata:LanguageId").text
        end
        @range_filters = xpath("mdata:NavigationAppliedFilters/mdata:RangeFilterList").children.collect do |filter|
          RangeFilter.from_element(filter)
        end
        
        #TODO: business rules
        #TODO: keyword redirects
        #TODO: analytics
      end
      
      def add_dimension_values!(values)
        values.each do |id, value|
          next if @dimension_values[id]
          @dimension_values[id] = value
          add_dimension_values!(value.values)
        end
      end
      
      def expose_all_refinements?
        @expose_all_refinements
      end
    end
  end
end
