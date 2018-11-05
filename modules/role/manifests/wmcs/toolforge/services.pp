class role::wmcs::toolforge::services {
    system::role { $name: }

    include profile::toolforge::apt_pinning
    include profile::toolforge::grid::base
    include profile::toolforge::services::basic
    include profile::toolforge::services::aptly
    include profile::toolforge::services::bigbrother
    include profile::toolforge::services::updatetools
}
