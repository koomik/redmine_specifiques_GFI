require_dependency 'timelog_controller'

module GCT_TPS_CRA_patch_timelog
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :new, :patch
    end
  end
  
  module InstanceMethods
    def new_with_patch
		@time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :spent_on => User.current.today)
		@time_entry.safe_attributes = params[:time_entry]
	end
	
  end
end

TimelogController.send(:include, GCT_TPS_CRA_patch_timelog)
