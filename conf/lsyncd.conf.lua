settings {
    logfile = "/var/log/lsyncd/lsyncd.log",
    statusFile = "/var/log/lsyncd/lsyncd-status.log",
    statusInterval = 20
}

sync {
    default.rsync,
    source="/var/backups/cardanonode",
    target="{username}@rsync.keycdn.com:{zone}/",
    rsync = {
        archive = false,
        acls = false,
        chmod = "D2755,F644",
        compress = true,
        links = false,
        owner = false,
        perms = false,
        verbose = true,
        rsh = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
    }
}
