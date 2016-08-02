module Luban
  module Deployment
    module Packages
      class Nginx
        class Configurator < Luban::Deployment::Service::Configurator
          include Controller::Commands

          def error_log_file_path
            @error_log_file_path ||= log_path.join(error_log_file_name)
          end

          def error_log_file_name
            @error_log_file_name ||= "#{service_name}.error.log"
          end

          def log_file_name
            @log_file_name ||= "#{service_name}.access.log"
          end

          alias_method :access_log_file_path, :log_file_path
          alias_method :access_log_file_name, :log_file_name

          def mime_types_file_path
            @mime_types_file_path ||=
              if file?(stage_profile_path.join(mime_types_file_name))
                profile_path.join(mime_types_file_name)
              else
                current_path.join('conf').join(mime_types_file_name)
              end
          end

          def mime_types_file_name
            @mime_types_file_name ||= 'mime.types'
          end

          def proxy_app; task.opts.proxy_app; end
          def proxy_to; task.opts.proxy_to end
          def proxy?; !!proxy_to; end

          def proxy_control_file_path
            @proxy_control_file_path ||= 
              project_path.join(proxy_to.to_s, 'shared', 'profile', proxy_to.to_s).
                           join(proxy_control_file_name)
          end

          def proxy_control_file_name
            @proxy_control_file_name ||= "#{proxy_app.web_server[:name]}.nginx.http.proxy.conf"
          end
        end
      end
    end
  end
end
