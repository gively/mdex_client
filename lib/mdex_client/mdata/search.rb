require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class Search < Node
      MODES = %w(All AllAny AllPartial Any Boolean Partial PartialMax Unknown)
    
      attr_accessor :key, :query, :relevance_ranking_strategy, :mode, :snippet_length, 
        :enable_snippeting
        
      def write_xml!(xml)
        attributes = { "Key" => key }
        %w(RelevanceRankingStrategy Mode SnippetLength EnableSnippeting).each do |attribute|
          value = send(attribute.underscore)
          attributes[attribute] = value.to_s if value
        end
        
        xml.mdata :Search, attributes, query
      end
      
      def mode=(new_mode)
        if new_mode.nil?
          @mode = nil
        else
          new_mode_normalized = new_mode.to_s.classify
          
          if MODES.include?(new_mode_normalized)
            @mode = new_mode_normalized
          else
            raise "#{new_mode} is not a valid mode.  Valid modes are: #{MODES.join(", ")}"
          end
        end
      end
    end
  end
end
