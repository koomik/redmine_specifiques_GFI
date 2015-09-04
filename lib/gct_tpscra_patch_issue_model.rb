require_dependency 'issue'

module GCT_TPS_CRA_patch_issue_model
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
   # Returns the total number of hours 'temps CRA' for this issue and its descendants
   def gct_tpscra_hours
		demis = time_entries.count(:conditions => "gct_tpscra='M' or gct_tpscra='S'")
		jours = time_entries.count(:conditions => "gct_tpscra='J'")
		total = (demis * 4) + (jours * 8)
   end
   
   
   def save_issue_with_child_records(params, existing_time_entry=nil)
    Issue.transaction do
      if params[:time_entry] && params[:time_entry][:hours].present? && User.current.allowed_to?(:log_time, project)
        @time_entry = existing_time_entry || TimeEntry.new
        @time_entry.project = project
        @time_entry.issue = self
        @time_entry.user = User.find_by_id(params[:time_entry][:user_id])
        @time_entry.spent_on = Date.today
        @time_entry.attributes = params[:time_entry]
        self.time_entries << @time_entry
      end
  
      if valid?
        attachments = Attachment.attach_files(self, params[:attachments])
  
        attachments[:files].each {|a| @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => a.id, :value => a.filename)}
        # TODO: Rename hook
        Redmine::Hook.call_hook(:controller_issues_edit_before_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
        begin
          if save
            # TODO: Rename hook
            Redmine::Hook.call_hook(:controller_issues_edit_after_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
          else
            raise ActiveRecord::Rollback
          end
        rescue ActiveRecord::StaleObjectError
          attachments[:files].each(&:destroy)
          errors.add_to_base l(:notice_locking_conflict)
          raise ActiveRecord::Rollback
        end
      end
    end
  end
   

  
  end
end

Issue.send(:include, GCT_TPS_CRA_patch_issue_model)
