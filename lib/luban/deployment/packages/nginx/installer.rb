module Luban
  module Deployment
    module Packages
      class Nginx
        class Installer < Luban::Deployment::Service::Installer
          include Configurator::Paths

          default_executable 'nginx'

          def source_repo
            @source_repo ||= "http://nginx.org"
          end

          def source_url_root
            @source_url_root ||= "download"
          end

          def installed?
            return false unless file?(nginx_executable)
            pattern = "nginx version: nginx/#{package_major_version}"
            match?("#{nginx_executable} -v 2>&1", pattern)
          end

          def with_opt_dir(dir)
            @cc_opts << "-I #{dir.join('include')}"
            @ld_opts << "-L #{dir.join('lib')} -Wl,-rpath,#{dir.join('lib')}"
          end
          alias_method :with_pcre_dir, :with_opt_dir
          alias_method :with_openssl_dir, :with_opt_dir

          protected

          def configure_build_options
            super
            @configure_opts.unshift('--with-http_stub_status_module')
            @configure_opts.unshift('--with-stream')
            @configure_opts.unshift('--with-http_ssl_module')
            @configure_opts.unshift('--with-http_gzip_static_module')
            @cc_opts = []
            @ld_opts = []
          end

          def compose_build_options
            @configure_opts << "--with-cc-opt=\"#{@cc_opts.join(' ')}\""
            @configure_opts << "--with-ld-opt=\"#{@ld_opts.join(' ')}\""
            super
          end
        end
      end
    end
  end
end