module Luban
  module Deployment
    module Packages
      class Nginx < Luban::Deployment::Service::Base
        apply_to :all do
          before_install do
            depend_on 'pcre', version: '8.38'
            depend_on 'openssl', version: '1.0.2h'
          end
        end

        def default_templates_path
          @default_templates_path ||= Pathname.new(File.join(File.dirname(__FILE__), 'templates')).realpath
        end

        %i(config_test quit_process reload_process reopen_logs).each do |action|
          service_action action, dispatch_to: :controller
        end

        protected

        def setup_install_tasks
          super
          commands[:install].option :pcre, "PCRE version"
          commands[:install].option :openssl, "OpenSSL version"
        end

        def setup_control_tasks
          super

          task :config_test do
            desc "Syntax check on config file"
            action! :config_test
          end

          task :quit do
            desc "Stop process gracefully"
            action! :quit_process
          end

          task :reload do
            desc "Reload process"
            action! :reload_process
          end

          task :reopen do
            desc "Reopen log files"
            action! :reopen_logs
          end
        end
      end
    end
  end
end