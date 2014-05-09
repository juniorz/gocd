##########################GO-LICENSE-START################################
# Copyright 2014 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################GO-LICENSE-END##################################

Go::Application.routes.draw do

  unless defined?(CONSTANTS)
    USER_NAME_FORMAT = ROLE_NAME_FORMAT = GROUP_NAME_FORMAT = TEMPLATE_NAME_FORMAT = PIPELINE_NAME_FORMAT = STAGE_NAME_FORMAT = ENVIRONMENT_NAME_FORMAT = /[\w\-][\w\-.]*/
    JOB_NAME_FORMAT = /[\w\-.]+/
    PIPELINE_COUNTER_FORMAT = STAGE_COUNTER_FORMAT = /-?\d+/
    NON_NEGATIVE_INTEGER = /\d+/
    PIPELINE_LOCATOR_CONSTRAINTS = {:pipeline_name => PIPELINE_NAME_FORMAT, :pipeline_counter => PIPELINE_COUNTER_FORMAT}
    STAGE_LOCATOR_CONSTRAINTS = {:stage_name => STAGE_NAME_FORMAT, :stage_counter => STAGE_COUNTER_FORMAT}.merge(PIPELINE_LOCATOR_CONSTRAINTS)
    ENVIRONMENT_NAME_CONSTRAINT = {:name => ENVIRONMENT_NAME_FORMAT}

    CONSTANTS = true
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'home' => 'pipelines#index', as: :welcome_page

  # map.with_options(:controller => "admin/pipelines",
  #   :requirements => {
  #     :stage_parent => "pipelines",
  #     :pipeline_name => PIPELINE_NAME_FORMAT,
  #     :current_tab => /#{["general", "project_management", "environment_variables", "permissions", "parameters"].join("|")}/
  # }) do |pipeline|
  #   pipeline.pipeline_edit "admin/pipelines/:pipeline_name/:current_tab", :action => "edit",  :conditions => {:method => :get}
  #   pipeline.pipeline_update "admin/pipelines/:pipeline_name/:current_tab", :action => "update", :conditions => {:method => :put}
  # end

  # pipeline_edit_path => edit_pipelines_path
  scope '/admin' do
    resource :pipelines, only: [:edit, :update]
  end

  # map.with_options(:controller => "admin/pipeline_groups") do |groups|
  #   groups.pipeline_groups "admin/pipelines", :action => "index"
  #   groups.pipeline_group_new "admin/pipeline_group/new", :action => "new", :conditions => {:method => :get}
  #   groups.pipeline_group_create "admin/pipeline_group", :action => "create", :conditions => {:method => :post}
  #   groups.move_pipeline_to_group "admin/pipelines/move/:pipeline_name", :action => "move", :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT}, :conditions => {:method => :put}
  #   groups.delete_pipeline "admin/pipelines/:pipeline_name", :action => "destroy", :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT}, :conditions => {:method => :delete}
  #   groups.pipeline_group_edit "admin/pipeline_group/:group_name/edit", :action => "edit", :requirements => {:group_name => GROUP_NAME_FORMAT}, :conditions => {:method => :get}
  #   groups.pipeline_group_show "admin/pipeline_group/:group_name", :action => "show", :requirements => {:group_name => GROUP_NAME_FORMAT}, :conditions => {:method => :get}
  #   groups.pipeline_group_update "admin/pipeline_group/:group_name", :action => "update", :requirements => {:group_name => GROUP_NAME_FORMAT}, :conditions => {:method => :put}
  #   groups.pipeline_group_delete "admin/pipeline_group/:group_name", :action => "destroy_group", :requirements => {:group_name => GROUP_NAME_FORMAT}, :conditions => {:method => :delete}
  #   groups.possible_groups "/admin/pipelines/possible_groups/:pipeline_name/:config_md5", :action => "possible_groups", :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT}, :conditions => {:method => :get}
  # end

  scope '/admin' do
    resource :pipeline_groups
  end

  # map.with_options(:no_layout=>true) do |no_layout|
  #   no_layout.api_pipeline_action 'api/pipelines/:pipeline_name/:action', :action=> ':action', :controller=>'api/pipelines', :pipeline_name => PIPELINE_NAME_FORMAT, :conditions => {:method => :post}
  #
  #   no_layout.pause_pipeline 'api/pipelines/:pipeline_name/pause', :controller=>'api/pipelines', :action => 'pause', :conditions => {:method => :post}, :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT}
  #   no_layout.unpause_pipeline 'api/pipelines/:pipeline_name/unpause', :controller=>'api/pipelines', :action => 'unpause', :conditions => {:method => :post}, :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT}
  #   no_layout.cancel_stage "api/stages/:id/cancel", :controller => "api/stages", :action => "cancel"
  #   no_layout.cancel_stage_using_pipeline_stage_name "api/stages/:pipeline_name/:stage_name/cancel", :controller => "api/stages", :action => "cancel_stage_using_pipeline_stage_name"
  #   no_layout.material_notify "api/material/notify/:post_commit_hook_material_type", :controller => "api/materials", :action => "notify", :conditions => {:method => :post}
  #
  #   no_layout.match 'api/plugins/status', :action => 'status', :controller => 'api/plugins'
  #   no_layout.match 'api/users/:username', :action => 'destroy', :controller => 'api/users', :conditions => {:method => :delete}, :requirements => {:username => USER_NAME_FORMAT}
  #   no_layout.with_options(:format => 'xml') do |xml_routes|
  #     xml_routes.with_options(:controller => 'api/pipelines') do |pipeline_api|
  #       pipeline_api.api_pipeline_stage_feed 'api/pipelines/:name/stages.xml', :action=> 'stage_feed', :conditions => {:method => :get}, :requirements => {:name => PIPELINE_NAME_FORMAT}
  #       pipeline_api.api_pipeline_instance 'api/pipelines/:name/:id.xml', :action=> 'pipeline_instance', :conditions => {:method => :get}, :requirements => {:name => PIPELINE_NAME_FORMAT}
  #       pipeline_api.card_activity "api/card_activity/:pipeline_name/:from_pipeline_counter/to/:to_pipeline_counter", :action => 'card_activity', :no_layout => true, :conditions => {:method => :get}, :requirements => {:from_pipeline_counter => PIPELINE_COUNTER_FORMAT, :to_pipeline_counter => PIPELINE_COUNTER_FORMAT, :pipeline_name => PIPELINE_NAME_FORMAT}
  #       pipeline_api.api_pipelines 'api/pipelines.xml', :action=> 'pipelines', :conditions => {:method => :get}
  #     end
  #
  #     xml_routes.job 'api/jobs/scheduled.xml', :action=> 'scheduled', :controller=> 'api/jobs'
  #     xml_routes.job 'api/jobs/:id.xml', :action=> 'index', :controller=> 'api/jobs'
  #
  #     xml_routes.stage 'api/stages/:id.xml', :action=> 'index', :controller=> 'api/stages'
  #
  #     xml_routes.server 'api/server.xml', :action=> 'info', :controller=> 'api/server', :format => 'xml'
  #     xml_routes.server 'api/support', :action=> 'capture_support_info', :controller=> 'api/server', :format => 'text'
  #     xml_routes.match 'api/users.xml', :action => 'index', :controller => 'api/users'
  #
  #     xml_routes.material 'api/materials/:id.xml', :controller => "application", :action => "unresolved"
  #     xml_routes.modification 'api/materials/:materialId/changeset/:modificationId.xml', :controller => "application", :action => "unresolved"
  #
  #     xml_routes.server 'api/fanin_trace/:name', :action=> 'fanin_trace', :controller=> 'api/fanin_trace', :format => 'text', :requirements => {:name => PIPELINE_NAME_FORMAT}
  #     xml_routes.server 'api/fanin/:name', :action=> 'fanin', :controller=> 'api/fanin_trace', :format => 'text', :requirements => {:name => PIPELINE_NAME_FORMAT}
  #
  #     xml_routes.server 'api/process_list', :action=> 'process_list', :controller=> 'api/process_list', :format => 'text'
  #   end
  #
  #   no_layout.agents_information 'api/agents', :action => 'index', :controller => 'api/agents', :format => 'json', :conditions => {:method => :get}
  #   no_layout.api_disable_agent 'api/agents/edit_agents', :action => 'edit_agents', :controller => 'api/agents', :conditions => {:method => :post}
  #   no_layout.agent_action "api/agents/:uuid/:action", :controller => 'api/agents', :requirements => {:action => /enable|disable|delete/}, :conditions => {:method => :post}
  #
  #   no_layout.pipeline_material_search "pipelines/material_search", :controller => 'pipelines', :action => 'material_search', :conditions => {:method => :post}
  #   no_layout.pipeline_show_with_option "pipelines/show_for_trigger", :controller => 'pipelines', :action => 'show_for_trigger', :conditions => {:method => :post}
  #   no_layout.environment_new "environments/new", :controller => 'environments', :action => 'new', :conditions => {:method => :get}
  #   no_layout.environment_create "environments/create", :controller => 'environments', :action => 'create', :conditions => {:method => :post}
  #
  #   [:pipelines, :agents, :variables].each do |action|
  #     no_layout.send("environment_edit_#{action}", "environments/:name/edit/#{action}", :controller => 'environments', :action => "edit_#{action}", :conditions => {:method => :get}, :requirements => ENVIRONMENT_NAME_CONSTRAINT)
  #   end
  #   no_layout.environment_update "environments/:name", :controller => 'environments', :action => 'update', :conditions => {:method => :put},:requirements => ENVIRONMENT_NAME_CONSTRAINT
  #
  #   no_layout.backup_api_url "api/admin/start_backup", :controller => "api/admin", :action => "start_backup", :conditions => {:method => :post}
  #
  #   no_layout.admin_command_cache_reload "api/admin/command-repo-cache/reload", :action => "reload_cache", :controller => 'api/commands', :conditions => {:method => :post}
  # end

  with_options(no_layout: true) do
    post 'pipelines/show_for_trigger' => 'pipelines#show_for_trigger',
      as: :pipeline_show_with_option

    post 'api/pipelines/:pipeline_name/pause' => 'api/pipelines#pause',
         constraints: { pipeline_name: PIPELINE_NAME_FORMAT },
        as: :pause_pipeline

    # this should come last because it would have a higher priority and catch all previous routes
    post 'api/pipelines/:pipeline_name/:action', to: 'api/pipelines', action: ':action',
        constraints: { pipeline_name: PIPELINE_NAME_FORMAT },
        as: :api_pipeline_action
  end

  # map.with_options(:controller => "admin/templates") do |template|
  #   template.templates "admin/templates", :action => "index"
  #   template.template_new "admin/templates/new", :action => "new", :conditions => { :method => :get }
  #   template.template_create "admin/templates/create", :action => "create", :conditions => { :method => :post }
  #   template.delete_template "admin/templates/:pipeline_name", :action => "destroy", :requirements => { :pipeline_name => PIPELINE_NAME_FORMAT }, :conditions => { :method => :delete }
  #   template.edit_template_permissions "admin/templates/:template_name/permissions", :action => "edit_permissions", :requirements =>  { :template_name => TEMPLATE_NAME_FORMAT }, :conditions => { :method => :get }
  #   template.update_template_permissions "admin/templates/:template_name/permissions", :action => "update_permissions", :requirements =>  { :template_name => TEMPLATE_NAME_FORMAT }, :conditions => { :method => :post }
  #
  #   template.with_options(:controller => "admin/templates", :requirements => {:current_tab => /#{["general"].join("|")}/}) do |template|
  #     template.template_edit "admin/:stage_parent/:pipeline_name/:current_tab", :action => "edit", :requirements =>  { :pipeline_name => PIPELINE_NAME_FORMAT }, :conditions => { :method => :get }
  #     template.template_update "admin/:stage_parent/:pipeline_name/:current_tab", :action => "update", :requirements =>  { :pipeline_name => PIPELINE_NAME_FORMAT }, :conditions => { :method => :put }
  #   end
  # end

  #==> templates_path
  scope '/admin' do
    resources :templates
  end

  # map.with_options(:controller => "config_view/templates") do |config_view_templates|
  #   config_view_templates.config_view_templates_show "/config_view/templates/:name", :action => "show", :requirements =>  { :name => PIPELINE_NAME_FORMAT }, :conditions => { :method => :get }
  # end

  get 'config_view/templates/:name' => 'config_view/templates#show',
    defaults: {:name => "KINGNALDO"}, #TODO fixme
    constraints: { :name => PIPELINE_NAME_FORMAT },
    as: :config_view

  # map.edit_server_config "admin/config/server", :controller => "config/server", :action => "index"
  # map.update_server_config "admin/config/server/update", :controller => "config/server", :action => "update", :conditions => {:method => :post}
  # map.validate_server_config_params "admin/config/server/validate", :controller => "config/server", :action => "validate", :conditions => {:method => :get}

  scope '/admin/config' do
    resource :server , only: [:index, :update], as: :server_config do
      get 'validate', :on => :member
    end
  end

  # map.with_options(:controller => "users") do |admin|
  #   admin.user_listing "admin/users", :action => "users"
  # end
  # TODO users#users, really?
  get 'admin/users' => 'users#users', as: :user_listing

  # TODO missing
  get '/missing' => 'missing#missing', as: :oauth_clients
  get '/missing' => 'missing#missing', as: :gadgets_oauth_clients

  # map.with_options(:controller => "admin/backup") do |controller|
  #   controller.perform_backup "admin/backup", :action => "perform_backup", :conditions => {:method => :post}
  #   controller.backup_server "admin/backup",  :action => "index", :conditions => {:method => :get}
  #   controller.delete_backup_history "admin/backup/delete_all",  :action => "delete_all", :conditions => {:method => :delete} #NOT_IN_PRODUCTION don't remove this line, the build will remove this line when packaging the war
  # end

  scope '/admin' do
    with_options(controller: 'admin/backup') do
      get 'backup' => 'admin/backup#index', as: :backup_server

      # controller.perform_backup "admin/backup", :action => "perform_backup", :conditions => {:method => :post}
      # controller.backup_server "admin/backup",  :action => "index", :conditions => {:method => :get}
      # controller.delete_backup_history "admin/backup/delete_all",  :action => "delete_all", :conditions => {:method => :delete} #NOT_IN_PRODUCTION don't remove this line, the build will remove this line when packaging the war
    end
  end

  # map.with_options(:controller => "admin/plugins/plugins") do |plugins|
  #   plugins.plugins_listing "admin/plugins", :action => "index", :conditions => {:method => :get}
  # end

  get '/admin/plugins' => 'admin/plugins/plugins#index', as: :plugins_listing

  # map.with_options(:controller => "admin/package_repositories") do |package_repositories|
  #   package_repositories.package_repositories "admin/package_repositories", :action => "index", :conditions => { :method => :get }
  #   package_repositories.package_repositories_new "admin/package_repositories/new", :action => "new", :conditions => { :method => :get }
  #   package_repositories.package_repositories_check_connection "admin/package_repositories/check_connection", :action => "check_connection", :conditions => { :method => :get }
  #   package_repositories.package_repositories_list "admin/package_repositories/list", :action => "list", :conditions => { :method => :get }
  #   package_repositories.package_repositories_edit "admin/package_repositories/:id/edit", :action => "edit", :conditions => { :method => :get }
  #   package_repositories.package_repositories_create "admin/package_repositories", :action => "create", :conditions => { :method => :post }
  #   package_repositories.package_repositories_update "admin/package_repositories/:id", :action => "update", :conditions => { :method => :put }
  #   package_repositories.package_repositories_delete "admin/package_repositories/:id", :action => "destroy", :conditions => { :method => :delete }
  #   package_repositories.package_repositories_plugin_config "admin/package_repositories/:plugin/config/", :action => "plugin_config", :conditions => { :method => :get }
  #   package_repositories.package_repositories_plugin_config_for_repo "admin/package_repositories/:id/:plugin/config/", :action => "plugin_config_for_repo", :conditions => { :method => :get }
  # end

  scope '/admin' do
    resources :package_repositories
  end

  get 'server/messages.json' => 'server#messages', as: :global_message

  # map.pipeline_dashboard "pipelines", :controller => 'pipelines', :action => 'index', :conditions => {:method => :get}
  # map.build_cause "pipelines/:pipeline_name/:pipeline_counter/build_cause", :controller => 'pipelines', :action => 'build_cause', :no_layout => true, :conditions => {:method => :get}, :requirements => PIPELINE_LOCATOR_CONSTRAINTS
  # map.vsm_show "pipelines/value_stream_map/:pipeline_name/:pipeline_counter.:format", :controller => 'value_stream_map', :action => 'show', :conditions => {:method => :get}, :defaults => {:format => :html}, :requirements => {:pipeline_name => PIPELINE_NAME_FORMAT, :pipeline_counter => PIPELINE_COUNTER_FORMAT}
  # map.welcome_page "home", :controller => 'pipelines', :action => 'index', :conditions => {:method => :get}, :format => "html"
  # map.pipeline "pipelines/:action", :controller => 'pipelines', :conditions => {:method => :post}

  resource :pipelines, as: :pipeline do
    post 'select_pipelines', on: :member
  end

  root :controller => "java", :action => "null"
end
