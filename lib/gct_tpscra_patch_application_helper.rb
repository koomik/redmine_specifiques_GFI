require_dependency 'application_helper'

module GCT_TPS_CRA_patch_application_helper
  def self.included(base)
    base.send(:include, InstanceMethodsHelper)
  end
  
  module InstanceMethodsHelper 
   def html_gct_tpscra(textin)
	case textin
		when "A"
			textout = "Aucun"
		when "M"
			textout = "Matin"
		when "S"
			textout = "Soir"
		when "J"
			textout = "Jour"
		else
			textout = "(inconnu)"
	end
	return textout
  end
    
  end
end

ApplicationHelper.send(:include, GCT_TPS_CRA_patch_application_helper)
