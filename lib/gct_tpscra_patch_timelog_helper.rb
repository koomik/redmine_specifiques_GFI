require_dependency 'timelog_helper'

module GCT_TPS_CRA_patch_helper_timelog
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethodsHelper)
	
	base.class_eval do
		alias_method_chain :report_to_csv, :patch
	end
  end
  
  module InstanceMethodsHelper
	def gct_tpscra_collection_for_select_options()
		collection = []
		collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
		collection << [ "Aucun", "A" ]
		collection << [ "Matin", "M" ]
		collection << [ "Soir", "S" ]
		collection << [ "Jour", "J" ]
		collection
	end
	
	# Adds a rates tab to the user administration page
    def report_to_csv_with_patch
      decimal_separator = l(:general_csv_decimal_separator)
	  Redmine::Export::CSV.generate do |csv|
      # Column headers
      headers = [l(:field_spent_on),
                 l(:field_user),
                 l(:field_activity),
                 l(:field_project),
                 l(:field_issue),
                 l(:field_tracker),
                 l(:field_subject),
				 l(:field_gct_tpscra),
                 l(:field_hours),
                 l(:field_comments)
                 ]
      # Export custom fields
      headers += custom_fields.collect(&:name)
      headers << l(:label_total_time)
      csv << headers
      # Content
      report_criteria_to_csv(csv, report.available_criteria, report.columns, report.criteria, report.periods, report.hours)
      # Total row
      str_total = l(:label_total_time)
      row = [ str_total ] + [''] * (report.criteria.size - 1)
      total = 0
      report.periods.each do |period|
        sum = sum_hours(select_hours(report.hours, report.columns, period.to_s))
        total += sum
        sum_r = (sum > 0 ? "%.2f" % sum : '')
        row << sum_r.to_s.gsub('.', decimal_separator)
      end
      total_r = "%.2f" %total
      row << total_r.to_s.gsub('.', decimal_separator)
      csv << row
    end
  end
	
	
  end
end

TimelogHelper.send(:include, GCT_TPS_CRA_patch_helper_timelog)
