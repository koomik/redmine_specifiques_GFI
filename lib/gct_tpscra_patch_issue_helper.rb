require_dependency 'issues_helper'

module GCT_TPS_CRA_patch_helper_issues
  def self.included(base)
    base.send(:include, InstanceMethodsHelper)
  end
  
  module InstanceMethodsHelper
	# Ajout de la méthode l_days
	# Renvoie le nombre de jours équivalent (1 jour=8h)
	def l_days(hours)
       days = hours.to_f / 8.0
       l((days < 2.0 ? :label_f_day : :label_f_day_plural), :value => ("%.2f" % days.to_f))
    end
  end
end

IssuesHelper.send(:include, GCT_TPS_CRA_patch_helper_issues)
