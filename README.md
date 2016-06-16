## TODO

    * add more flexible control over output
    * option: sort sample /etc/hosts by hostnames (first hostname)
    * option: only beautify, no analyze
    * tests!

## Samples

### Analyze

    Addresses:
    195.34.2.40 found on all hosts. Names: storage-1
    195.34.2.15 found on 2 hosts (...). Names: video-1 cnv-1
    192.168.14.1 found on 1 hosts (...). Name: data-1 upload-3
    192.168.14.2 found on 1 host (...). Name: data-2 upload-4

    Names:
    storage-1 found on all hosts. Address: ...
    video-1   found on 3 hosts (...). Addresses: ... ...

### Generate

    # loopback interfaces skipped
    # ipv6 skipped
    # real
    x.x.x.x rec-1
    x.x.x.x v-1-1, cnv-v-1-1
    # local
    192.168.1.1 data-1 upload-3
    192.168.1.2 data-2 upload-4