#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Chef::Knife::NodeList do
  before(:each) do
    @knife = Chef::Knife::NodeList.new
    @knife.stub!(:output).and_return(true)
    @list = {
      "foo" => "http://example.com/foo",
      "bar" => "http://example.com/foo"
    }
    Chef::Node.stub!(:list).and_return(@list)
  end

  describe "run" do
    it "should list the nodes" do
      Chef::Node.should_receive(:list).and_return(@list)
      @knife.run
    end

    it "should pretty print the list" do
      Chef::Node.should_receive(:list).and_return(@list)
      @knife.should_receive(:output).with([ "bar", "foo" ])
      @knife.run
    end

    describe "with -w or --with-uri" do
      it "should pretty print the hash" do
        @knife.config[:with_uri] = true
        Chef::Node.should_receive(:list).and_return(@list)
        @knife.should_receive(:output).with(@list)
        @knife.run
      end
    end
  end
end

