module Luban
  module Deployment
    module Packages
      class Nginx
        class Controller < Luban::Deployment::Service::Controller
          include Configurator::Paths

          default_executable 'nginx'

          def nginx_command
            @nginx_command ||= "#{nginx_executable} -c #{control_file_path}"
          end
          alias_method :process_pattern, :nginx_command

          def config_test
            update_result config_test!
          end

          def quit_process
            if process_stopped?
              update_result "Skipped! Already stopped #{package_full_name}", status: :skipped
              return
            end

            output = quit_process!
            if check_until { process_stopped? }
              unmonitor_process
              update_result "Gracefully stop #{package_full_name}: [OK] #{output}"
            else
              remove_orphaned_pid_file
              update_result "Gracefully stop #{package_full_name}: [FAILED] #{output}",
                            status: :failed, level: :error
            end
          end

          def before_quit; unmonitor_process; end

          def reload_process
            update_result reload_process!
          end

          def reopen_logs
            update_result reopen_logs!
          end

          protected

          def config_test!
            capture("#{nginx_command} -t 2>&1")
          end

          def start_process!
            capture("#{nginx_command} 2>&1")
          end

          def quit_process!
            capture("#{nginx_command} -s quit 2>&1")
          end

          def stop_process!
            capture("#{nginx_command} -s stop 2>&1")
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