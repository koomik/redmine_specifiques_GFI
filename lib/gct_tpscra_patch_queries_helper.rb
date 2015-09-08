require_dependency 'queries_helper'

module GCT_TPS_CRA_patch_helper_queries
  def self.included(base)
    base.send(:include, InstanceMethodsHelper)
	
	base.class_eval do
		#alias_method_chain :query_to_csv, :patch
	end
  end
  
  module InstanceMethodsHelper
	def query_to_csv_timelog(items, query, options={})
    #columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
	decimal_separator = l(:general_csv_decimal_separator)
	custom_fields = TimeEntryCustomField.all.to_a
	columns = [l(:field_spent_on),
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
      columns += custom_fields.collect(&:name)
	
	query.available_block_columns.each do |column|
      if options[column.name].present?
        columns << column
      end
    end

    Redmine::Export::CSV.generate do |csv|
      # csv header fields
      csv << columns
      # csv lines
      items.each do |entry|
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
  end
  end
end

QueriesHelper.send(:include, GCT_TPS_CRA_patch_helper_queries)
