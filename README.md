## TODO

    * more informative warnings
    * option: skip conflicts
    * option: same name with local and real addr are not conflicted
    * option: sort sample /etc/hosts by hostnames (first hostname)
    * option: only beautify, no analyze
    * tests!

## Samples

### Analyze addresses

    ::1              found on all hosts. Multiple entries: ip6-localhost, ip6-loopback, localhost
    xxx.xxx.xxx.xxx  found on all hosts. Entry: office
    xxx.xxx.xxx.xxx  found on all hosts. Multiple entries: v-1-1, cnv-v-1-1
    xxx.xxx.xxx.xxx  found on 1 host: hosts1. Multiple entries: bl, bl1

### Analyze names

    office           found on all hosts. Entry: xxx.xxx.xxx.xxx
    cnv-v-1-1        found on all hosts. Entry: xxx.xxx.xxx.xxx
    v-1-1            found on all hosts. Entry: xxx.xxx.xxx.xxx
    bl1              found on 1 host. Multiple entries: xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx

### Generate

    # loopback interfaces skipped
    # ipv6 skipped
    # real
    xxx.xxx.xxx.xxx  office
    xxx.xxx.xxx.xxx  v-1-1 cnv-v-1-1
    # local
    192.168.1.1      bl1    
    192.168.1.2      bl1    