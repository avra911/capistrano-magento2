##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require 'capistrano-pending'

before :deploy, 'deploy:pending:check_changes'
namespace :deploy do

  # Check for pending changes on the primary node and then notify user of any incoming
  # changes and/or warn that there is nothing to deploy
  namespace :pending do
    task :check_changes do
      on primary fetch(:magento_deploy_setup_role) do
        # check for pending changes only if REVISION file exists to prevent error
        if test "[ -f #{current_path}/REVISION ]"
          invoke 'deploy:pending:setup'
          from = fetch(:revision)
          to = fetch(:branch)

          output = _scm.log(from, to, true)
          if output.to_s.strip.empty?
            puts "\e[0;31m      No changes to deploy (from and to are the same: #{from}..#{to})"
            print "      Are you sure you want to continue? [y/n] \e[0m"

            proceed = STDIN.gets[0..0] rescue nil
            exit unless proceed == 'y' || proceed == 'Y'
          else
            puts "\e[0;90m      Deploying changes #{from}..#{to}:\e[0m"
            output.each_line do |s|
              puts "      " + s
            end
          end
        end
      end
    end
  end
end
