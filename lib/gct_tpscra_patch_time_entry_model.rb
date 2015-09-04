require_dependency 'time_entry'

module GCT_TPS_CRA_patch_time_entry_model
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
	base.class_eval do
	
		attr_protected :project_id, :tyear, :tmonth, :tweek
		clear_validators! # On supprime toutes les contraintes de validation
		
		# Le Temps CRA est obligatoire
		validates_presence_of :user_id, :activity_id, :project_id, :hours, :spent_on, :gct_tpscra
		
		# On remet les autres contraintes de validation
		validates_numericality_of :hours, :allow_nil => true, :message => :invalid
		validates_length_of :comments, :maximum => 255, :allow_nil => true
		validates :spent_on, :date => true
		
		# Définition des valeurs admissibles du champ Temps CRA
		@@valid_units = ["A", "M", "S", "J"]
		
		# On vérifie que la valeur du Temps CRA saisie est bien incluse dans la liste de valeurs admissibles
		validates_inclusion_of :gct_tpscra, :in=>@@valid_units, :message=> :inclusion
		
		safe_attributes 'hours', 'comments', 'project_id', 'issue_id', 'activity_id', 'spent_on', 'custom_field_values', 'custom_fields', 'gct_tpscra'

    end
  end
  
  
  module InstanceMethods
  end
  
end

TimeEntry.send(:include, GCT_TPS_CRA_patch_time_entry_model)
