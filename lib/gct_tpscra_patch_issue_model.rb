require_dependency 'issue'

module GCT_TPS_CRA_patch_issue_model
  def self.included(base)
    base.send(:include, InstanceMethods)
	
	base.class_eval do
      alias_method :done_ratio_derived?, :done_ratio_derived_with_patch?
    end
	
  end
  
  module InstanceMethods
	# Returns the total number of hours 'temps CRA' for this issue and its descendants
	def gct_tpscra_hours
		demis = time_entries.where("gct_tpscra='M' or gct_tpscra='S'").count
		jours = time_entries.where("gct_tpscra='J'").count
		total = 4*demis + 8*jours
	end
	
	def done_ratio_derived_with_patch?
		false
	end
  end
end

Issue.send(:include, GCT_TPS_CRA_patch_issue_model)
