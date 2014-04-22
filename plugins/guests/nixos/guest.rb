module VagrantPlugins
  module GuestNixOS
    class Guest < Vagrant.plugin("2", :guest)
      def detect?(machine)
        machine.communicate.test("cat /etc/nixos/configuration.nix")
      end
    end
  end
end
