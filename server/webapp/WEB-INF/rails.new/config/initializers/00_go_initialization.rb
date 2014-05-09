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

#ENV['ADMIN_OAUTH_URL_PREFIX'] = "admin"
#ENV['LOAD_OAUTH_SILENTLY'] = "yes"

SHINE_PLATFORM = 'cruise' unless defined? SHINE_PLATFORM
ENV["RAILS_ASSET_ID"] = File.readlines(Rails.root.join("../vm/admin/admin_version.txt.vm")).first

Rails.application.config.after_initialize do |app|
  require 'log4j_logger'

  app.config.time_zone = 'UTC'
  app.config.logger = Log4jLogger.new
end
