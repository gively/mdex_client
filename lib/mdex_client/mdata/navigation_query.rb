require 'mdex_client/mdata/node'
require 'mdex_client/mdata/sort'
require 'mdex_client/mdata/search'

module MDEXClient
  module MData
    class NavigationQuery < Node
      attr_accessor :selected_dimension_value_ids, :refinement_configs, 
        :expose_all_refinements, :aggregation_key,
        :record_offset, :records_per_page, :included_record_attributes, :sorts,
        :business_rules_filter, :business_rules_preview_time, :eql_expression,
        :record_filter, :range_filters, :searches, :enable_did_you_mean, :analytics_expression,
        :user_profiles, :language_id, :dimension_value_strata, :alternative_phrasing_mode
        
      def write_xml!(xml)
        if selected_dimension_value_ids
          xml.mdata :SelectedDimensionValueIds do
            selected_dimension_value_ids.each do |id|
              xml.mdata :DimensionValueId, id
            end
          end
        end
        
        if refinement_configs || expose_all_refinements
          params = {}
          params["ExposeAllRefinements"] = true if expose_all_refinements
          xml.mdata :RefinementConfigs, params do
            if refinement_configs
              refinement_configs.each do |conf|
                conf.write_xml!(xml)
              end
            end
          end
        end
        
        aggregation_key.try(:write_xml!)
        xml.mdata :RecordOffset, record_offset if record_offset
        xml.mdata :RecordsPerPage, records_per_page if records_per_page
        
        if included_record_attributes
          xml.mdata :IncludedRecordAttributes do
            included_record_attributes.each do |a|
              xml.mdata :IncludedRecordAttribute, a
            end
          end
        end
        
        if sorts
          xml.mdata :Sorts do
            sorts.each do |sort|
              sort.write_xml!(xml)
            end
          end
        end
        
        xml.mdata :BusinessRulesFilter, business_rules_filter if business_rules_filter
        if business_rules_preview_time
          xml.mdata :BusinessRulesPreviewTime, 
            business_rules_preview_time.utc.strftime("%Y-%m-%dT%H:%M:%S")
        end
        
        xml.mdata :EqlExpression, eql_expression if eql_expression
        xml.mdata :RecordFilter, record_filter if record_filter
        
        if searches && searches.any? { |key, search| search.query.present? }
          searches_attrs = {}
          searches_attrs["EnableDidYouMean"] = enable_did_you_mean.to_s if enable_did_you_mean
          xml.mdata :Searches, searches_attrs do
            searches.each do |key, search|
              next unless search.query.present?
              search.write_xml!(xml)
            end
          end
        end
      end
      
      def sorts=(new_sorts)
        @sorts = convert_items(new_sorts, Sort)
      end
      
      def searches=(new_searches)
        @searches = new_searches.inject({}) do |memo, (key, params)|
          memo[key] = case params
          when Search
            params
          when Hash
            Search.new(params.merge(:key => key))
          else
            raise "Can't initialize a Search using #{params.inspect}"
          end
          
          memo
        end
      end
      
      def refinement_configs=(new_rcs)
        @refinement_configs = convert_items(new_rcs, RefinementConfig)
      end
      
      def main_search_query
        @searches ||= {}
        @searches["mainSearch"].try(:query)
      end
      
      def main_search_query=(query)
        @searches ||= {}
        @searches["mainSearch"] ||= Search.new
        @searches["mainSearch"].key = "mainSearch"
        @searches["mainSearch"].query = query
        @searches["mainSearch"].enable_snippeting = true
        @searches["mainSearch"].snippet_length = 100
      end
      
      protected
      def convert_items(arr, klass)
        arr.collect do |item|
          if item.is_a?(klass)
            item
          else
            klass.new(item)
          end
        end
      end
    end
  end
end
