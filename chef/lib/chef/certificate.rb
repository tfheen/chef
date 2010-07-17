#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
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

require 'chef/log'
require 'chef/config'
require 'chef/api_client'
require 'openssl'
require 'fileutils'

class Chef
  class Certificate
    class << self
  
      # Creates a new key pair
      #
      # @param [String] The common name for the key pair.
      # @param [Optional String] The subject alternative name.
      # @return [Object, Object] The public and private key objects.
      def gen_keypair(common_name, subject_alternative_name = nil)

        Chef::Log.info("Creating new key pair for #{common_name}")

        # generate client keypair
        private_key = OpenSSL::PKey::RSA.generate(2048)

        return private_key.public_key(), private_key
      end

      def gen_validation_key(name=Chef::Config[:validation_client_name], key_file=Chef::Config[:validation_key], admin=false)
        # Create the validation key
        api_client = Chef::ApiClient.new
        api_client.name(name)
        api_client.admin(admin)
        
        begin
          # If both the couch record and file exist, don't do anything. Otherwise,
          # re-generate the validation key.
          Chef::ApiClient.cdb_load(name)
          
          # The couch document was loaded successfully if we got to here; if we
          # can't also load the file on the filesystem, we'll regenerate it all.
          File.open(key_file, "r") do |file|
          end
        rescue Chef::Exceptions::CouchDBNotFound
          create_validation_key(api_client, key_file)
        rescue
          if $!.class.name =~ /Errno::/
            Chef::Log.error("Error opening validation key: #{$!} -- destroying and regenerating")
            begin
              api_client.cdb_destroy
            rescue Bunny::ServerDownError => e
              # create_validation_key is gonna fail anyway, so let's just bail out.
              Chef::Log.fatal("Could not de-index (to rabbitmq) previous validation key - rabbitmq is down! Start rabbitmq then restart chef-server to re-generate it")
              raise
            end
            
            create_validation_key(api_client, key_file)
          else
            raise
          end
        end
      end
      
      private
      def create_validation_key(api_client, key_file)
        Chef::Log.info("Creating validation key...")

        api_client.create_keys
        begin
          api_client.cdb_save
        rescue Bunny::ServerDownError => e
          # If rabbitmq is down, the client will have been saved in CouchDB,
          # but not in the index.
          Chef::Log.fatal("Could not index (to rabbitmq) validation key - rabbitmq is down! Start rabbitmq then restart chef-server to re-generate it")

          # re-raise so the error bubbles out and nukes chef-server
          raise e
        end
        
        key_dir = File.dirname(key_file)
        FileUtils.mkdir_p(key_dir) unless File.directory?(key_dir)
        File.open(key_file, File::WRONLY|File::CREAT, 0600) do |f|
          f.print(api_client.private_key)
        end
        FileUtils.chown("root", "root", key_file)
      end

    end
  end
end
