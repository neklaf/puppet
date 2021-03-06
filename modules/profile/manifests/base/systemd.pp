class profile::base::systemd(
    Enum['yes', 'no'] $systemd_cpu_accounting = lookup('profile::base::systemd::cpu_accounting'),
    Enum['yes', 'no'] $systemd_blockio_accounting = lookup('profile::base::systemd::blockio_accounting'),
    Enum['yes', 'no'] $systemd_memory_accounting = lookup('profile::base::systemd::memory_accounting'),
    Enum['yes', 'no'] $systemd_ip_accounting = lookup('profile::base::systemd::ip_accounting'),
) {
    requires_os('debian >= buster')

    class { '::systemd::config':
        cpu_accounting     => $systemd_cpu_accounting,
        blockio_accounting => $systemd_blockio_accounting,
        memory_accounting  => $systemd_memory_accounting,
        ip_accounting      => $systemd_ip_accounting,
    }
}
