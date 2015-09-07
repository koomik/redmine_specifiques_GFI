require_dependency 'issue'

module GCT_TPS_CRA_patch_issue_model
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
	# Returns the total number of hours 'temps CRA' for this issue and its descendants
	def gct_tpscra_hours
		demis = time_entries.where("gct_tpscra='M' or gct_tpscra='S'").count
		jours = time_entries.where("gct_tpscra='J'").count
		total = 4*demis + 8*jours
	end
  end
end

Issue.send(:include, GCT_TPS_CRA_patch_issue_model)
