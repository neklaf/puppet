# == Class profile::scap::dsh
#
# Installs the dsh files used by scap on a host
class profile::scap::dsh(
    $groups = hiera('scap::dsh::groups'),
    $proxies = hiera('scap::dsh::scap_proxies', []),
    $masters = hiera('scap::dsh::scap_masters', []),
    $conftool_prefix = hiera('conftool_prefix'),
) {
    class { 'confd':
        interval => 300,
        prefix   => $conftool_prefix,
    }

    class { '::scap::dsh':
        groups       => $groups,
        scap_proxies => $proxies,
        scap_masters => $masters,
    }

    # Special-case file for the MediaWiki canaries
    # These need to change according to the MediaWiki active datacenter.
    # We also want the servers from each cluster in their own canary list.
    $canary_dcs = ['eqiad', 'codfw']
    $canary_clusters = ['appserver', 'api_appserver', 'jobrunner', 'parsoid']

    $canary_clusters.each |$cl| {
        # Cosmetic fix to get the same filenames as before
        $dsh_name = $cl ? {
            'api_appserver' => 'api',
            default => $cl
        }
        # We also need mediawiki-config to get the active DC.
        $keys = $canary_dcs.map |$dc| { "/pool/${dc}/${cl}/canary" } + '/mediawiki-config'
        confd::file { "/etc/dsh/group/mediawiki-${dsh_name}-canaries":
            ensure     => present,
            content    => template('profile/scap/dsh-mediawiki-canaries.tpl.erb'),
            watch_keys => $keys,
        }
    }
}
