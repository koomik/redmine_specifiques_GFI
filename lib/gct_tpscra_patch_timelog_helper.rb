require_dependency 'timelog_helper'

module GCT_TPS_CRA_patch_helper_timelog
  def self.included(base)
    base.send(:include, InstanceMethodsHelper)
	
	base.class_eval do
		alias_method_chain :report_to_csv, :patch
		alias_method_chain :report_criteria_to_csv, :patch
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
      ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')    
    decimal_separator = l(:general_csv_decimal_separator)
    custom_fields = TimeEntryCustomField.find(:all)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
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
      
      csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      # csv lines
      entries.each do |entry|
        fields = [format_date(entry.spent_on),
                  entry.user,
                  entry.activity,
                  entry.project,
                  (entry.issue ? entry.issue.id : nil),
                  (entry.issue ? entry.issue.tracker : nil),
                  (entry.issue ? entry.issue.subject : nil),
				  entry.gct_tpscra,
                  entry.hours.to_s.gsub('.', decimal_separator),
                  entry.comments
                  ]
        fields += custom_fields.collect {|f| show_value(entry.custom_value_for(f)) }
                  
        csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      end
    end
    export
    end

	def report_criteria_to_csv_with_patch(csv, available_criteria, columns, criteria, periods, hours, level=0)
    decimal_separator = l(:general_csv_decimal_separator)
	hours.collect {|h| h[criteria[level]].to_s}.uniq.each do |value|
      hours_for_value = select_hours(hours, criteria[level], value)
      next if hours_for_value.empty?
      row = [''] * level
      row << format_criteria_value(available_criteria[criteria[level]], value).to_s
      row += [''] * (criteria.length - level - 1)
      total = 0
      periods.each do |period|
        sum = sum_hours(select_hours(hours_for_value, columns, period.to_s))
        total += sum
        sum_r = (sum > 0 ? "%.2f" % sum : '')
        row << sum_r.to_s.gsub('.', decimal_separator)
      end
      total_r = "%.2f" %total
      row << total_r.to_s.gsub('.', decimal_separator)
      csv << row
      if criteria.length > level + 1
        report_criteria_to_csv(csv, available_criteria, columns, criteria, periods, hours_for_value, level + 1)
      end
    end
  end
	
	
  end
end

TimelogHelper.send(:include, GCT_TPS_CRA_patch_helper_timelog)
