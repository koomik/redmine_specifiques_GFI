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
      decimal_separator = l(:general_csv_decimal_separator)
	  Redmine::Export::CSV.generate do |csv|
		  # Column headers
		  headers = report.criteria.collect {|criteria| l(report.available_criteria[criteria][:label]) }
		  headers += report.periods
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
