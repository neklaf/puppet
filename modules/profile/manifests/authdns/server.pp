class profile::authdns::server (
    Hash $lvs_services = lookup('lvs::configuration::lvs_services'),
    Hash $discovery_services = lookup('discovery::services'),
    Hash[String, Hash[String, String]] $authdns_addrs = lookup('authdns_addrs'),
    Array[String] $authdns_servers = lookup('authdns_servers'),
    Stdlib::HTTPSUrl $gitrepo = lookup('profile::authdns::server::gitrepo'),
) {
    include ::profile::base::firewall
    include ::profile::authdns::acmechief_target

    class { 'prometheus::node_gdnsd': }

    create_resources(
        interface::ip,
        $authdns_addrs,
        { interface => 'lo', prefixlen => '32' }
    )

    class { 'authdns':
        nameservers        => $authdns_servers,
        gitrepo            => $gitrepo,
        lvs_services       => $lvs_services,
        discovery_services => $discovery_services,
    }

    ferm::service { 'udp_dns_auth':
        proto   => 'udp',
        notrack => true,
        port    => '53',
    }

    ferm::service { 'tcp_dns_auth':
        proto => 'tcp',
        port  => '53',
    }

    $authdns_ns_ferm = join($authdns_servers, ' ')
    ferm::service { 'authdns_update_ssh':
        proto  => 'tcp',
        port   => '22',
        srange => "(@resolve((${authdns_ns_ferm})) @resolve((${authdns_ns_ferm}), AAAA))",
    }

    # Enable TFO, which gdnsd-3.x supports by default if enabled
    sysctl::parameters { 'TCP Fast Open for AuthDNS':
        values => {
            'net.ipv4.tcp_fastopen' => 3,
        },
    }

    # Enable RPS/RSS stuff.  Current authdns hosts have tg3 or bnx2 1G cards,
    # but it still helps!
    interface::rps { 'primary':
        interface => $facts['interface_primary'],
    }
}
