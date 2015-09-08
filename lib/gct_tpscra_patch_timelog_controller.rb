require_dependency 'timelog_controller'

module GCT_TPS_CRA_patch_timelog
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
		# Redéfinition des méthodes new, create, index et report
		alias_method_chain :new, :patch
		alias_method_chain :create, :patch
		alias_method_chain :index, :patch
		alias_method_chain :report, :patch
    end
  end
  
  module InstanceMethods
    def new_with_patch
		@time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :spent_on => User.current.today)
		@time_entry.safe_attributes = params[:time_entry]
	end
	
	def create_with_patch
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :spent_on => User.current.today)
    @time_entry.safe_attributes = params[:time_entry]
	@time_entry.user = User.find_by_id(params[:time_entry][:user_id]) # Ligne spécifique GFI (possibilité d'assigner du temps passé à un membre du projet)
    if @time_entry.project && !User.current.allowed_to?(:log_time, @time_entry.project)
      render_403
      return
    end

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            options = {
              :time_entry => {
                :project_id => params[:time_entry][:project_id],
                :issue_id => @time_entry.issue_id,
                :activity_id => @time_entry.activity_id
              },
              :back_url => params[:back_url]
            }
            if params[:project_id] && @time_entry.project
              redirect_to new_project_time_entry_path(@time_entry.project, options)
            elsif params[:issue_id] && @time_entry.issue
              redirect_to new_issue_time_entry_path(@time_entry.issue, options)
            else
              redirect_to new_time_entry_path(options)
            end
          else
            redirect_back_or_default project_time_entries_path(@time_entry.project)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end
  
  
	def index_with_patch
    @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')
    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = time_entry_scope(:order => sort_clause).
      includes(:project, :user, :issue).
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])
		respond_to do |format|
			format.html {
			@entry_count = scope.count
			@entry_pages = Redmine::Pagination::Paginator.new @entry_count, per_page_option, params['page']
			@entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
			@total_hours = scope.sum(:hours).to_f

			render :layout => !request.xhr?
		}
		format.api  {
			@entry_count = scope.count
			@offset, @limit = api_offset_and_limit
			@entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
		}
		format.atom {
			entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
			render_feed(entries, :title => l(:label_spent_time))
		}
		format.csv {
			@entries = scope.to_a
		
			#Ligne modifiée (spécifique GFI) : Modification du nom du fichier à générer et de la méthode à appeler (query_to_csv_timelog au lieu de query_to_csv)
			send_data(query_to_csv_timelog(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog_details.csv')
		}
		end
	end
  
	def report_with_patch
		@query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')
		scope = time_entry_scope

		@report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)

		respond_to do |format|
			format.html { render :layout => !request.xhr? }
      
			#Ligne modifiée (spécifique GFI) : Modification du nom du fichier à générer
			format.csv  { send_data(report_to_csv(@criterias, @periods, @hours), :type => 'text/csv; header=present', :filename => 'timelog_report.csv') }
		end
	end
	
  end
end

TimelogController.send(:include, GCT_TPS_CRA_patch_timelog)
