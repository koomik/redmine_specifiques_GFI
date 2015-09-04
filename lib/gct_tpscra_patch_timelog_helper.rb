require_dependency 'timelog_helper'

module GCT_TPS_CRA_patch_helper_timelog
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethodsHelper)
  end
  
  module InstanceMethodsHelper
	def gct_tpscra_collection_for_select_options()
		collection = []
		collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
		collection << [ "Aucun", "A" ]
		collection << [ "Matin", "M" ]
		collection << [ "Soir", "S" ]
		collection << [ "Jour", "J" ]
		collection
	end
  end
end

TimelogHelper.send(:include, GCT_TPS_CRA_patch_helper_timelog)
