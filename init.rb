require 'redmine'
require 'gct_tpscra_patch_application_helper'
require 'gct_tpscra_patch_timelog_helper'
require 'gct_tpscra_patch_issue_helper'

require 'gct_tpscra_patch_timelog_controller'

require 'gct_tpscra_patch_issue_model'
require 'gct_tpscra_patch_time_entry_model'

Redmine::Plugin.register :redmine_patch_gct_tpscra do
  name 'Correctif : Mise en place du Temps CRA'
  author 'GCT Orthez'
  description 'Patch spécifique GFI pour prendre en compte les Temps CRA (correspondance avec Resplan)'
  version '1.0.0'
  
  requires_redmine :version_or_higher => '3.0.0'
  
end
