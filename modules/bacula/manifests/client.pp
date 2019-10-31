# Class: bacula::client
#
# This class installs bacula-fd, configures it and ensures that it is running
#
# Parameters:
#   $director
#       The FQDN of the server being our director
#   $catalog
#       Which bacula catalog will be used for this client
#   $file_retention
#       How much time the catalog will hold data about files
#   $job_retention
#       How much time the catalog will hold data about jobs
#   $fd_port
#       If needed to change the port the fd listens on. Default 9102
#
# Actions:
#       Install bacula-fd, configure, ensure running
#       The director password is autogenerated and exported
#       Exports configuration to bacula-director
#       Defines a virtual resource for a bpipe mysql plugin
#
# Requires:
#
# Sample Usage:
#       class { 'bacula::client':
#           director    => 'dir.example.com',
#       }
#
class bacula::client(
                    $director,
                    $catalog,
                    $file_retention,
                    $job_retention,
                    $directorpassword,
                    $fdport='9102',
) {

    package { 'bacula-fd':
        ensure => installed,
    }

    service { 'bacula-fd':
        ensure  => running,
        require => Package['bacula-fd'],
    }

    base::expose_puppet_certs { '/etc/bacula':
        provide_private => true,
        provide_keypair => true,
        user            => 'bacula',
        group           => 'bacula',
        require         => Package['bacula-fd'],
    }

    file { '/etc/bacula/bacula-fd.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
        notify  => Service['bacula-fd'],
        content => template('bacula/bacula-fd.conf.erb'),
        require => [
                    Package['bacula-fd'],
                ],
    }

    # We export oufself to the director
    @@file { "/etc/bacula/clients.d/${::fqdn}.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'bacula',
        mode    => '0440',
        content => template('bacula/bacula-client.erb'),
        notify  => Service['bacula-director'],
        tag     => "bacula-client-${director}",
    }
}
