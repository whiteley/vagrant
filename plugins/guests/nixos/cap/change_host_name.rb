module VagrantPlugins
  module GuestNixOS
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          machine.communicate.tap do |comm|
            if !comm.test("sudo hostname --fqdn | grep '#{name}'")
              comm.sudo("sed -i 's@^\\([[:space:]]\\+networking[.]hostName[[:space:]]\\+[=][[:space:]]\\+\\)\"[^\"]*\";@\\1\"#{name.split('.')[0]}\";@' /etc/nixos/configuration.nix")
              comm.sudo("nixos-rebuild switch")
            end
          end
        end
      end
    end
  end
end
