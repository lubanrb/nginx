module Luban
  module Deployment
    module Packages
      class Nginx
        class Controller < Luban::Deployment::Service::Controller
          module Commands
            def self.included(base)
              base.define_executable 'nginx'
            end

            def bin_path
              @bin_path ||= install_path.join('sbin')
            end

            def nginx_command
              @nginx_command ||= "#{nginx_executable} -c #{control_file_path}"
            end

            def process_pattern
              @process_pattern ||= "^nginx: master process #{nginx_command}"
            end
            
            alias_method :start_command, :nginx_command

            def stop_command
              @stop_command ||= "#{nginx_command} -s stop"
            end
          end

          include Commands

          %w(config_test reload_process reopen_logs).each do |method|
            define_method(method) do
              update_result send("#{method}!")
            end
          end

          def quit_process
            if process_stopped?
              update_result "Skipped! Already stopped #{package_full_name}", status: :skipped
              return
            end

            unmonitor_process
            output = quit_process!
            if check_until { process_stopped? }
              update_result "Gracefully stop #{package_full_name}: [OK] #{output}"
            else
              remove_orphaned_pid_file
              update_result "Gracefully stop #{package_full_name}: [FAILED] #{output}",
                            status: :failed, level: :error
            end
          end

          protected

          def config_test!
            capture("#{nginx_command} -t 2>&1")
          end

          def quit_process!
            capture("#{nginx_command} -s quit 2>&1")
          end

          def reload_process!
            capture("#{nginx_command} -s reload 2>&1")
          end

          def reopen_logs!
            capture("#{nginx_command} -s reopen 2>&1")
          end
        end
      end
    end
  end
end
