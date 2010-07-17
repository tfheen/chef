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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

require 'chef/certificate'
require 'ostruct'
require 'tempfile'

class FakeFile
  attr_accessor :data

  def write(arg)
    @data = arg
  end
end

describe Chef::Certificate do
  describe "generate_keypair" do

    it "should return a client certificate" do
      cert, key = Chef::Certificate.gen_keypair("oasis")
      cert.to_s.should =~ /BEGIN RSA PUBLIC KEY/
      key.to_s.should =~ /BEGIN RSA PRIVATE KEY/
    end
  end
end
