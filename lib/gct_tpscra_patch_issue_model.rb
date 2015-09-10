require_dependency 'issue'

module GCT_TPS_CRA_patch_issue_model
  def self.included(base)
    base.send(:include, InstanceMethods)
	
	base.class_eval do
		# Redéfinition de la méthode done_ratio_derivated
		# On utilise la méthode "alias_method" et non "alias_method_chain" (problème avec le ? à la fin de la méthode)
      alias_method :done_ratio_derived?, :done_ratio_derived_with_patch? 
    end
	
  end
  
  module InstanceMethods
	# Ajout de la méthode gct_tpscra_hours
	# Returns the total number of hours 'temps CRA' for this issue and its descendants
	def gct_tpscra_hours
	
		# Ces 3 lignes permettent de retourner le nombre d'heures passées (Temps CRA renseigné) en considérant qu'un matin=4h, qu'un soir=4h et qu'un jour=8h
		# Peu importe la valeur saisie dans le champ Heures
		
		demis = time_entries.where("gct_tpscra='M' or gct_tpscra='S'").count
		jours = time_entries.where("gct_tpscra='J'").count
		total = 4*demis + 8*jours
		
		# Cette ligne renvoie le nombre d'heures passées (Temps CRA renseigné) en sommant toutes les heures des temps CRA
		# total = time_entries.where("gct_tpscra='M' or gct_tpscra='S' or gct_tpscra='J'").sum(:hours)
	end
	
	# Redéfinition de la méthode done_ratio_derivated?
	def done_ratio_derived_with_patch?
		false # On peut aussi commenter le code situé dans toutes les conditions (if p.done_ratio_derived?)
	end
  end
end

Issue.send(:include, GCT_TPS_CRA_patch_issue_model)
