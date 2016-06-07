require 'luban'

module Luban
  module Deployment
    module Packages
      class Pcre < Luban::Deployment::Package::Base
        class Installer < Luban::Deployment::Package::Installer
          def pcre_executable
            @default_executable ||= bin_path.join('pcre-config')
          end

          def source_repo
            @source_repo ||= "http://sourceforge.net"
          end

          def source_url_root
            @source_url_root ||= "projects/pcre/files/pcre/#{@package_major_version}"
          end

          def installed?
            return false unless file?(pcre_executable)
            match?("#{pcre_executable} --version", package_major_version)
          end

          protected
          
          def update_binstubs!; end
        end
      end
    end
  end
end
