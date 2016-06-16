# Class: tilerator::ui
#
# This class installs and configures tilerator::ui
#
# While only being a thin wrapper around service::node, this class exists to
# accomodate future tileratorui needs that are not suited for the service module
# classes as well as conform to a de-facto standard of having a module for every
# service
# NOTE: Tileratorui is a STATEFUL service. This is in contrast to all other
# services. It allows change of the configuration on the fly via the web
# interface. Specifically it is possible to change the sources as well as other
# parts of the configuration to allow insertion of jobs into the queue with
# different configuration (e.g. style) than the current one. It's been discussed
# that this needs to be revisited and done better in the future. It is rather
# innocuous right now as no users apart from an administrative user ever access
# it. tileratorui does not have an LVS service associated with it. It is
# only meant to be used through an SSH tunnel
# NOTE: The above is THE reason this service is separated from the tilerator
# service
#
# === Parameters
#
# [*conf_sources*]
#   Sources that will be added to the configuration file of the service. This
#   defines the data transformation pipeline for the tile services. The actual
#   file is loaded from the root of the source code directory.
#   (/srv/deployment/tilerator/deploy/src/)
#   Default: 'sources.prod.yaml'
#
# [*contact_groups*]
#   Contact groups for alerting.
#   Default: 'admins'
#
class tilerator::ui(
    $conf_sources   = 'sources.prod.yaml',
    $contact_groups = 'admins',
) {
    $cassandra_tileratorui_user = 'tileratorui'
    $cassandra_tileratorui_pass = hiera('maps::cassandra_tileratorui_pass')
    $pgsql_tileratorui_user = 'tileratorui'
    $pgsql_tileratorui_pass = hiera('maps::postgresql_tileratorui_pass')
    $redis_server = hiera('maps::redis_server')

    service::node { 'tileratorui':
        port           => 6535,
        config         => template('tilerator/config_ui.yaml.erb'),
        no_workers     => 0, # 0 on purpose to only have one instance running
        repo           => 'tilerator/deploy',
        deployment     => 'scap3',
        contact_groups => $contact_groups,
    }
}
