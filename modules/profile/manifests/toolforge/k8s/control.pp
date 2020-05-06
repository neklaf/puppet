class profile::toolforge::k8s::control (
    Array[Stdlib::Fqdn] $etcd_hosts = lookup('profile::toolforge::k8s::etcd_nodes',     {default_value => ['localhost']}),
    Stdlib::Fqdn        $apiserver  = lookup('profile::toolforge::k8s::apiserver_fqdn', {default_value => 'k8s.example.com'}),
    String              $node_token = lookup('profile::toolforge::k8s::node_token',     {default_value => 'example.token'}),
    String              $calico_version = lookup('profile::toolforge::k8s::calico_version', {default_value => 'v3.8.0'}),
    Optional[String]    $encryption_key = lookup('profile::toolforge::k8s::encryption_key', {default_value => undef}),
) {
    class { '::profile::wmcs::kubeadm::control':
        etcd_hosts     => $etcd_hosts,
        apiserver      => $apiserver,
        node_token     => $node_token,
        calico_version => $calico_version,
        encryption_key => $encryption_key,
    }
    contain '::profile::wmcs::kubeadm::control'

    class { '::toolforge::k8s::config':
        encryption_key => $encryption_key,
    }
}
