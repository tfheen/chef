#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
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
#

require 'chef/knife'
require 'chef/node'
require 'chef/search/query'
require 'chef/json'

class Chef
  class Knife
    class NodeEdit < Knife

      banner "knife node edit NODE (options)"

      def run 
        @node_name = @name_args[0]

        if @node_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a node name")
          exit 1
        end

        begin
          edit_object(Chef::Node, @node_name)
        rescue Chef::Exceptions::NodeNotFound
          # We didn't find it, look for a node with the name set
          # to what we've been asked to edit
          begin
            q = Chef::Search::Query.new
            nodes = q.search(:node, "name:#{@node_name}*")
            if nodes[0].length == 1
              edit_object(Chef::Node, nodes[0][0].name)
            else
              node = ask_select_option("Which node do you want to edit?", nodes[0])
              edit_object(Chef::Node, node.name)
            end
          rescue NoMethodError
            raise Chef::Exceptions::NodeNotFound, "Node #{@node_name} not found"
          end
        end
      end
    end
  end
end


