require_dependency 'time_entry'

module GCT_TPS_CRA_patch_time_entry_model
  def self.included(base)
    base.send(:include, InstanceMethods)

	base.class_eval do
		unloadable
		alias_method_chain :validate_time_entry, :patch # Redéfinition de la méthode validate_time_entry

		attr_protected :project_id, :tyear, :tmonth, :tweek
		clear_validators! # On supprime toutes les contraintes de validation
		
		# Le Temps CRA est obligatoire
		validates_presence_of :user_id, :activity_id, :project_id, :hours, :spent_on, :gct_tpscra
		
		# On remet les autres contraintes de validation
		validates_numericality_of :hours, :allow_nil => true, :message => :invalid
		validates_length_of :comments, :maximum => 255, :allow_nil => true
		validates :spent_on, :date => true
		validate :validate_time_entry
		
		# Définition des valeurs admissibles du champ Temps CRA
		@@valid_units = ["A", "M", "S", "J"]
		
		# On vérifie que la valeur du Temps CRA saisie est bien incluse dans la liste de valeurs admissibles
		validates_inclusion_of :gct_tpscra, :in=>@@valid_units, :message=> :inclusion
		
		safe_attributes 'gct_tpscra'
    end
  end
  
  
  module InstanceMethods
	# Redéfinition de la méthode validate_time_entry
	def validate_time_entry_with_patch
		# Méthode originale (copié collé)
		errors.add :hours, :invalid if hours && (hours < 0 || hours >= 1000)
		errors.add :project_id, :invalid if project.nil?
		errors.add :issue_id, :invalid if (issue_id && !issue) || (issue && project!=issue.project) || @invalid_issue_id
		errors.add :activity_id, :inclusion if activity_id_changed? && project && !project.activities.include?(activity)

		# Controle sur la saisie dans le champ commentaire
		@@invalid_chars = "&*%?'#\""
		errors.add(:comments, :invalid_char, :value =>@@invalid_chars) if (comments =~ /[#{@@invalid_chars}]/)
		
		# Tests sur gct_tpscra:
		# On ne peut saisir au maximum : 
		# - Qu'un matin et un soir pour une journée donnée
		# - Ou qu'un jour pour une journée donnée
		if (id.nil?)
			conditions = [ "spent_on = ? and user_id = ?", spent_on, user_id ]
		else
			conditions = [ "spent_on = ? and user_id = ? and id != ?", spent_on, user_id, id ]
		end
		
		existants = TimeEntry.select(:gct_tpscra).where(conditions).collect{ |e| e.gct_tpscra }	
		case gct_tpscra
			when "M"
				errors.add :gct_tpscra, :not_two_mornings_or_day if (existants.include?("M") || existants.include?("J"))
			when "S"
				errors.add :gct_tpscra, :not_two_evenings_or_day if (existants.include?("S") || existants.include?("J"))
			when "J"
				errors.add(:gct_tpscra, :not_more_x_unit, :count => "1 jour") if (existants.include?("M") || existants.include?("S") || existants.include?("J"))
		end
	end
  end
end

TimeEntry.send(:include, GCT_TPS_CRA_patch_time_entry_model)
