require_dependency 'time_entry_query'

module GCT_patch_time_entry_model
  def self.included(base)
    base.send(:include, InstanceMethods)

	base.class_eval do
		unloadable
		alias_method_chain :initialize, :patch # Redéfinition de la méthode initialize
    end
  end
  
  
  module InstanceMethods
    # Redéfinition de la méthode intialize
    def initialize_with_patch(attributes=nil, *args)	    
	initialize_without_patch(attributes, args)
	add_filter('spent_on', 'w')
    end
  end
end

TimeEntryQuery.send(:include, GCT_patch_time_entry_model)
