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

require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe PipelinesController do

  before(:each)  do
    @stage_service = double('stage service')
    @material_service = double('material service')
    @user = Username.new(CaseInsensitiveString.new("foo"))
    @user_id = 1
    @status = HttpOperationResult.new
    HttpOperationResult.stub(:new).and_return(@status)
    @localized_result = HttpLocalizedOperationResult.new
    @subsection_result = SubsectionLocalizedOperationResult.new
    HttpLocalizedOperationResult.stub(:new).and_return(@localized_result)

    controller.stub(:populate_health_messages)
    controller.stub(:current_user).and_return(@user)
    controller.stub(:current_user_entity_id).and_return(@user_id)
    controller.stub(:stage_service).and_return(@stage_service)
    controller.stub(:material_service).and_return(@material_service)

    @pim = PipelineHistoryMother.singlePipeline("pipline-name", StageInstanceModels.new)
    controller.stub(:pipeline_history_service).and_return(@pipeline_history_service=double())
    controller.stub(:pipeline_lock_service).and_return(@pipieline_lock_service=double())
    controller.stub(:go_config_service).and_return(@go_config_service=double())
    controller.stub(:security_service).and_return(@security_service=double())
    @pipeline_identifier = PipelineIdentifier.new("blah", 1, "label")
    controller.stub(:populate_config_validity)
    @pipeline_service = double('pipeline_service')
    controller.stub(:pipeline_service).and_return(@pipeline_service)
  end

  describe "build_cause" do
    it "should render build cause" do
      @pipeline_history_service.should_receive(:findPipelineInstance).with("pipeline_name", 10, @user, @status).and_return(@pim)
      controller.should_receive(:render).with(:partial => "shared/build_cause_popup", :locals => {:scope => {:pipeline_instance => @pim}}, :layout => false)
      get :build_cause, :pipeline_name => "pipeline_name", :pipeline_counter => "10"
    end

    it "should render build cause" do
      @pipeline_history_service.should_receive(:findPipelineInstance) do |pipeline_name, pipeline_counter, user, result|
        result.error("not allowed", "you are so not allowed", HealthStateType.general(HealthStateScope::GLOBAL))
      end
      controller.should_receive(:render).with(:partial => "shared/build_cause_popup", :locals => {:scope => {:pipeline_instance => @pim}}).never
      controller.should_receive(:render_operation_result_if_failure).with(@status)
      get :build_cause, :pipeline_name => "pipeline_name", :pipeline_counter => "10", :layout => false
    end


    it "should route to build_cause action" do
      params_from(:get, "/pipelines/name_of_pipeline/15/build_cause").should == {:controller => "pipelines", :action => "build_cause", :pipeline_name => "name_of_pipeline", :pipeline_counter => "15", :no_layout => true}
    end

    it "should route to build_cause action with dots in pipline name" do
      params_from(:get, "/pipelines/blah.pipe-line/1/build_cause").should == {:controller => "pipelines", :action => "build_cause", :pipeline_name => "blah.pipe-line", :pipeline_counter => "1", :no_layout => true}
    end

    it "should have a named route" do
      controller.send(:build_cause_url, :pipeline_name => "foo", :pipeline_counter => 20).should == "http://test.host/pipelines/foo/20/build_cause"
    end
  end

  describe "index" do
    before(:each) do
      @selected_pipeline_id = "456"
      controller.stub(:cookies).and_return(cookiejar={:selected_pipelines => @selected_pipeline_id})
    end

    it "should load the dashboard" do
      @go_config_service.should_receive(:getSelectedPipelines).with(@selected_pipeline_id,@user_id).and_return(selections=PipelineSelections.new)
      @pipeline_history_service.should_receive(:allActivePipelineInstances).with(@user,selections).and_return(:pipeline_group_models)
      @security_service.should_receive(:viewableGroupsFor).with(@user).and_return(viewable_groups=PipelineConfigs.new)
      @security_service.should_receive(:canCreatePipelines).with(@user).and_return(true)

      get :index

      assigns[:pipeline_groups].should == :pipeline_group_models
      assigns[:pipeline_selections].should == selections
      assigns[:pipeline_configs].should == viewable_groups
    end

    it "should resolve" do
      params_from(:get, "/pipelines").should == {:controller => "pipelines", :action => "index"}
      params_from(:get, "/home").should == {:controller => "pipelines", :action => "index", :format=> "html"}
    end

    it "should redirect to 'add pipeline wizard' when there are no pipelines in config only if the user is an admin" do
      pipeline_group_models = java.util.ArrayList.new
      pipeline_group_models.add(PipelineGroupModel.new("bla"))
      @go_config_service.should_receive(:getSelectedPipelines).with(@selected_pipeline_id,@user_id).and_return(selections=PipelineSelections.new)
      @pipeline_history_service.should_receive(:allActivePipelineInstances).with(@user,selections).and_return(pipeline_group_models)
      @security_service.should_receive(:viewableGroupsFor).with(@user).and_return(viewable_groups=PipelineConfigs.new())
      @security_service.should_receive(:canCreatePipelines).with(@user).and_return(true)
      controller.stub(:url_for_path).with("/admin/pipeline/new?group=defaultGroup").and_return("/admin/pipeline/new?group=defaultGroup")

      get :index
      response.status.should == "302 Found"
      response.should have_tag("a[href=http://test.host/admin/pipeline/new?group=defaultGroup]")
    end

    it "should not redirect to 'add pipeline wizard' when there are no pipelines in config and the user is a template admin or is not an admin" do
      pipeline_group_models = java.util.ArrayList.new
      pipeline_group_models.add(PipelineGroupModel.new("bla"))
      @go_config_service.should_receive(:getSelectedPipelines).with(@selected_pipeline_id, @user_id).and_return(selections=PipelineSelections.new)
      @pipeline_history_service.should_receive(:allActivePipelineInstances).with(@user,selections).and_return(pipeline_group_models)
      @security_service.should_receive(:canCreatePipelines).with(@user).and_return(false)
      @security_service.should_receive(:viewableGroupsFor).with(@user).and_return(viewable_groups=PipelineConfigs.new())

      get :index
      response.status.should == "200 OK"
    end

    it "should not redirect to 'add pipeline wizard' when there are pipelines in config" do
      pipeline_group_models = java.util.ArrayList.new
      pipeline_group_models.add(PipelineGroupModel.new("bla"))
      viewable_groups = PipelineConfigMother::createGroup("blah", [PipelineConfigMother::createPipelineConfig("pip1", "stage1", ["job1"].to_java(:string))].to_java('com.thoughtworks.go.config.PipelineConfig'))
      @go_config_service.should_receive(:getSelectedPipelines).with(@selected_pipeline_id,@user_id).and_return(selections=PipelineSelections.new)
      @pipeline_history_service.should_receive(:allActivePipelineInstances).with(@user, selections).and_return(pipeline_group_models)
      @security_service.should_receive(:viewableGroupsFor).with(@user).and_return(viewable_groups)
      get :index
      response.status.should == "200 OK"
    end
  end

  describe "error_handling" do
    before do
      class << @controller
        include ActionRescue
      end
    end

    it "should handle exceptions and log errors" do
      nil.bomb rescue exception = $!
      RAILS_DEFAULT_LOGGER.should_receive(:error).with(%r{#{exception.message}}m)
      @controller.should_receive(:render_error_template)
      @controller.rescue_action(exception)
    end
  end

  describe "action show" do
    it "should load pipeline and variables for a given pipeline" do
      @pipeline_history_service.should_receive(:latest).with("blah-pipeline-name", @user).and_return(@pim)
      expected = EnvironmentVariablesConfig.new()
      expected.add("foo","foo_value")
      expected.add("bar","bar_value")
      @go_config_service.should_receive(:variablesFor).with("blah-pipeline-name").and_return(expected)
      get 'show', :pipeline_name => 'blah-pipeline-name'
      assigns[:pipeline].should == @pim
      assigns[:variables].should == expected
    end
  end

  describe "action show_for_trigger" do
    it "should load pipeline for a given pipeline" do
      @pipeline_history_service.should_receive(:latest).with("blah-pipeline-name", @user).and_return(@pim)
      expected = EnvironmentVariablesConfig.new()
      expected.add("foo","foo_value")
      expected.add("bar","bar_value")
      @go_config_service.should_receive(:variablesFor).with("blah-pipeline-name").and_return(expected)
      get 'show_for_trigger', :pipeline_name => 'blah-pipeline-name'
      assigns[:pipeline].should == @pim
    end

    it "should resolve get from /pipelines/show_for_trigger as a call" do
      params_from(:post, "/pipelines/show_for_trigger").should == {:controller => 'pipelines', :action => 'show_for_trigger', :no_layout => true}
    end

  end

  it "should resolve post to /pipelines/material_search as a call" do
    params_from(:post, "/pipelines/material_search").should == {:controller => 'pipelines', :action => 'material_search', :no_layout => true}
  end

  it "should show error message if the user is not authorized to view the pipeline" do
    @material_service.should_receive(:searchRevisions).with('pipeline', 'sha', 'search', @user, anything()) do |p,sha,search,user, result|
      result.unauthorized(LocalizedMessage.cannotViewPipeline("pipeline"), nil)
    end

    get :material_search, :pipeline_name => 'pipeline', :fingerprint => 'sha', :search => 'search'
    response.status.should == "401 Unauthorized"
  end

  it "should set up the matched revisions" do
    revisions = [MatchedRevision.new('search', '1', '1', 'me', java.util.Date.new, 'comment')]
    @material_service.should_receive(:searchRevisions).with('pipeline', 'sha', 'search', @user, anything()).and_return(revisions)
    pkg_config = MaterialConfigsMother.packageMaterialConfig()
    @go_config_service.should_receive(:materialForPipelineWithFingerprint).with('pipeline', 'sha').and_return(pkg_config)

    get :material_search, :pipeline_name => 'pipeline', :fingerprint => 'sha', :search => 'search'

    response.status.should == "200 OK"
    assigns[:matched_revisions].should == revisions
    assigns[:material_type].should == "PackageMaterial"
  end

  describe "select_pipelines with security disabled" do
    before do
      @go_config_service.should_receive(:isSecurityEnabled).and_return(false)
    end
    
    it "should set cookies for a selected pipelines" do
      @go_config_service.should_receive(:persistSelectedPipelines).with("456", @user_id, ["pipeline1", "pipeline2"]).and_return(1234)
      controller.stub(:cookies).and_return(cookiejar={:selected_pipelines => "456"})
      post "select_pipelines", "selector" => {:pipeline=>["pipeline1", "pipeline2"]}
      cookiejar[:selected_pipelines].should == {:value=>1234, :expires=>1.year.from_now.beginning_of_day}
    end

    it "should set cookies when no pipelines selected" do
      @go_config_service.should_receive(:persistSelectedPipelines).with("456", @user_id, []).and_return(1234)
      controller.stub(:cookies).and_return(cookiejar={:selected_pipelines => "456"})
      post "select_pipelines", "selector" => {}
      cookiejar[:selected_pipelines].should == {:value=>1234, :expires=>1.year.from_now.beginning_of_day}
    end

    it "should set cookies when no pipelines or groups selected" do
      @go_config_service.should_receive(:persistSelectedPipelines).with("456", @user_id, []).and_return(1234)
      controller.stub(:cookies).and_return(cookiejar={:selected_pipelines => "456"})
      post "select_pipelines"
      cookiejar[:selected_pipelines].should == {:value=>1234, :expires=>1.year.from_now.beginning_of_day}
    end
  end

  describe "select_pipelines with security enabled" do
    before do
      @go_config_service.should_receive(:isSecurityEnabled).and_return(true)
    end
    
    it "should not update set cookies for selected pipelines when security enabled" do
      @go_config_service.should_receive(:persistSelectedPipelines).with("456", @user_id, ["pipeline1", "pipeline2"]).and_return(1234)
      controller.stub(:cookies).and_return(cookiejar={:selected_pipelines => "456"})
      post "select_pipelines", "selector" => {:pipeline=>["pipeline1", "pipeline2"]}
      cookiejar[:selected_pipelines].should == "456"
    end

    it "should not set cookies when selected pipeline cookie is absent when security enabled" do
      @go_config_service.should_receive(:persistSelectedPipelines).with(nil, @user_id, []).and_return(1234)
      controller.stub(:cookies).and_return(cookiejar = {})
      post "select_pipelines", "selector" => {}
      cookiejar[:selected_pipelines].should == nil
    end
  end
end
