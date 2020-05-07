class profile::wmcs::kubeadm::control (
    Array[Stdlib::Fqdn] $etcd_hosts = lookup('profile::wmcs::kubeadm::etcd_nodes',     {default_value => ['localhost']}),
    Stdlib::Fqdn        $apiserver  = lookup('profile::wmcs::kubeadm::apiserver_fqdn', {default_value => 'k8s.example.com'}),
    String              $node_token = lookup('profile::wmcs::kubeadm::node_token',     {default_value => 'example.token'}),
    String              $calico_version = lookup('profile::wmcs::kubeadm::calico_version', {default_value => 'v3.8.0'}),
    Optional[String]    $encryption_key = lookup('profile::wmcs::kubeadm::encryption_key', {default_value => undef}),
) {
    require profile::wmcs::kubeadm::preflight_checks

    # use puppet certs to contact etcd
    $k8s_etcd_cert_pub  = '/etc/kubernetes/pki/puppet_etcd_client.crt'
    $k8s_etcd_cert_priv = '/etc/kubernetes/pki/puppet_etcd_client.key'
    $k8s_etcd_cert_ca   = '/etc/kubernetes/pki/puppet_ca.pem'
    $puppet_cert_pub    = "/var/lib/puppet/ssl/certs/${::fqdn}.pem"
    $puppet_cert_priv   = "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
    $puppet_cert_ca     = '/var/lib/puppet/ssl/certs/ca.pem'

    file { '/etc/kubernetes/pki':
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }
    file { $k8s_etcd_cert_pub:
        ensure    => present,
        source    => "file://${puppet_cert_pub}",
        show_diff => false,
        owner     => 'root',
        group     => 'root',
        mode      => '0444',
    }
    file { $k8s_etcd_cert_priv:
        ensure    => present,
        source    => "file://${puppet_cert_priv}",
        show_diff => false,
        owner     => 'root',
        group     => 'root',
        mode      => '0400',
    }
    file { $k8s_etcd_cert_ca:
        ensure => present,
        source => "file://${puppet_cert_ca}",
    }

    file { '/srv/git':
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',

    }

    git::clone { 'labs/tools/maintain-kubeusers':
        ensure    => present,
        directory => '/srv/git/maintain-kubeusers',
    }

    class { '::kubeadm::core': }
    class { '::kubeadm::docker': }

    # TODO: eventually we may need overriding this CIDR
    $pod_subnet = '192.168.0.0/16'
    class { '::kubeadm::init_yaml':
        etcd_hosts         => $etcd_hosts,
        apiserver          => $apiserver,
        pod_subnet         => $pod_subnet,
        node_token         => $node_token,
        k8s_etcd_cert_pub  => $k8s_etcd_cert_pub,
        k8s_etcd_cert_priv => $k8s_etcd_cert_priv,
        k8s_etcd_cert_ca   => $k8s_etcd_cert_ca,
        encryption_key     => $encryption_key,
    }

    class { '::kubeadm::calico_yaml':
        pod_subnet     => $pod_subnet,
        calico_version => $calico_version,
    }

    class { '::kubeadm::calico_workaround': }

    class { '::kubeadm::nginx_ingress_yaml': }

    class { '::kubeadm::admin_scripts': }

    class { '::kubeadm::metrics_yaml': }
}