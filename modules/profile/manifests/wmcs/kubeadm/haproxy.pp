class profile::wmcs::kubeadm::haproxy (
    Array[Stdlib::Fqdn] $worker_nodes  = lookup('profile::wmcs::kubeadn::worker_nodes',   {default_value => ['localhost']}),
    Stdlib::Port        $ingress_port  = lookup('profile::wmcs::kubeadm::ingress_port',   {default_value => 30000}),
    Array[Stdlib::Fqdn] $control_nodes = lookup('profile::wmcs::kubeadm::control_nodes',  {default_value => ['localhost']}),
    Stdlib::Port        $api_port      = lookup('profile::wmcs::kubeadm::apiserver_port', {default_value => 6443}),
) {
    requires_os('debian >= buster')

    package { 'haproxy':
        ensure => present,
    }

    file { '/etc/haproxy/conf.d':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/haproxy/haproxy.cfg':
        ensure  => present,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('profile/wmcs/kubeadm/haproxy/haproxy.cfg.erb'),
        notify  => Service['haproxy'],
    }

    file { '/etc/haproxy/conf.d/k8s-api-servers.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('profile/wmcs/kubeadm/haproxy/k8s-api-servers.cfg.erb'),
        notify  => Service['haproxy'],
    }

    file { '/etc/haproxy/conf.d/k8s-ingress.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('profile/wmcs/kubeadm/haproxy/k8s-ingress.cfg.erb'),
        notify  => Service['haproxy'],
    }

    # this file is loaded as environmentfile in the .service file shipped by
    # the debian package in Buster
    file { '/etc/default/haproxy':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "EXTRAOPTS='-f /etc/haproxy/conf.d/'\n",
        notify  => Service['haproxy'],
    }

    service { 'haproxy':
        ensure    => 'running',
        subscribe => [
                  File['/etc/haproxy/haproxy.cfg'],
                  File['/etc/haproxy/conf.d/k8s-api-servers.cfg'],
                  File['/etc/haproxy/conf.d/k8s-ingress.cfg'],
                  File['/etc/default/haproxy'],
        ],
    }

    class { 'prometheus::haproxy_exporter': }
}
