require "ipaddr"
require "tempfile"

require "vagrant/util/template_renderer"

module VagrantPlugins
  module GuestNixOS
    module Cap
      class ConfigureNetworks
        include Vagrant::Util

        def self.configure_networks(machine, networks)
          machine.communicate.tap do |comm|
            # Generate each network configuration
            interfaces = {}
            networks.each do |n|
              if n[:type].to_sym == :static
                prefix = IPAddr.new(n[:netmask]).to_i.to_s(2).index('0') || 32
                interfaces[n[:interface]] = "{ ipAddress = \"#{n[:ip]}\"; prefixLength = #{prefix}; };"
              end
            end

            # Render the network configuration module
            config = TemplateRenderer.render("guests/nixos/network", :options => interfaces)

            # Upload the module to a temporary location
            temp = Tempfile.new("vagrant")
            temp.binmode
            temp.write(config)
            temp.close

            # Activate the new configuration
            comm.upload(temp.path, "/tmp/vagrant-networks.nix")
            comm.sudo("mv /tmp/vagrant-networks.nix /etc/nixos/vagrant-networks.nix")
            comm.sudo("nixos-rebuild switch")
          end
        end
      end
    end
  end
end
