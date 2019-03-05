# cirrus checks
define icinga::monitor::elasticsearch::cirrus_checks(
    Enum['http', 'https'] $scheme = 'http',
    String $host = $::fqdn,
    Wmflib::IpPort $port = 9200,
) {
    monitoring::service { "elasticsearch / cirrus frozen writes - ${host}:${port}":
        host          => $host,
        check_command => "check_cirrus_frozen_writes!${scheme}!${port}",
        description   => "ElasticSearch health check for frozen writes - ${port}",
        critical      => true,
        contact_group => 'admins,team-discovery',
        notes_url     => 'https://wikitech.wikimedia.org/wiki/Search#Pausing_Indexing',
    }
}
