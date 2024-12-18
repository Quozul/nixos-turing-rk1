{
  stdenv,
  linuxManualConfig,
  inputs,
  flex,
  bison,
  perl,
  ...
}:
let
  src = inputs.kernel;
in
linuxManualConfig {
  inherit src;

  version = "6.13.0-rc2";

  configfile = stdenv.mkDerivation {
    inherit src;
    name = "kernel-config";

    nativeBuildInputs = [
      flex
      bison
      perl
    ];

    postPatch = ''
      patchShebangs scripts/config
    '';

    buildPhase = ''
      make defconfig
      scripts/config --module CONFIG_CRYPTO_USER_API_HASH

      # Enable nf_tables, required for the firewall and docker
      scripts/config --module CONFIG_NF_TABLES
      scripts/config --enable CONFIG_NF_TABLES_INET
      scripts/config --module CONFIG_NFT_NAT
      scripts/config --module CONFIG_NFT_CT
      scripts/config --enable CONFIG_NF_TABLES_NETDEV
      scripts/config --module CONFIG_NFT_NUMGEN
      scripts/config --module CONFIG_NETFILTER_NETLINK_HOOK
      scripts/config --module CONFIG_NFT_NUMGEN
      scripts/config --module CONFIG_NFT_CT
      scripts/config --module CONFIG_NFT_CONNLIMIT
      scripts/config --module CONFIG_NFT_LOG
      scripts/config --module CONFIG_NFT_LIMIT
      scripts/config --module CONFIG_NFT_MASQ
      scripts/config --module CONFIG_NFT_REDIR
      scripts/config --module CONFIG_NFT_NAT
      scripts/config --module CONFIG_NFT_TUNNEL
      scripts/config --module CONFIG_NFT_QUOTA
      scripts/config --module CONFIG_NFT_REJECT
      scripts/config --module CONFIG_NFT_REJECT_INET
      scripts/config --module CONFIG_NFT_COMPAT
      scripts/config --module CONFIG_NFT_HASH
      scripts/config --module CONFIG_NFT_SOCKET
      scripts/config --module CONFIG_NFT_OSF
      scripts/config --module CONFIG_NFT_TPROXY
      scripts/config --module CONFIG_NFT_SYNPROXY
      scripts/config --module CONFIG_NF_DUP_NETDEV
      scripts/config --module CONFIG_NFT_DUP_NETDEV
      scripts/config --module CONFIG_NFT_FWD_NETDEV
      scripts/config --module CONFIG_NFT_REJECT_NETDEV
      scripts/config --module CONFIG_NETFILTER_XTABLES
      scripts/config --module CONFIG_NETFILTER_XT_MATCH_PKTTYPE
      scripts/config --module CONFIG_NETFILTER_XT_MATCH_COMMENT
      scripts/config --module CONFIG_NETFILTER_XT_MATCH_STATISTIC

      # Enable RAID 1
      scripts/config --module CONFIG_MD_RAID1

      # Enable vxlan for k8s flannel
      scripts/config --module CONFIG_VXLAN
      scripts/config --module CONFIG_NF_FLOW_TABLE
      scripts/config --enable CONFIG_NF_FLOW_TABLE_PROCFS
      scripts/config --module CONFIG_NETFILTER_XT_TARGET_CT
      scripts/config --module CONFIG_NFT_DUP_IPV4
      scripts/config --module CONFIG_NFT_FIB_IPV4
      scripts/config --enable CONFIG_NF_TABLES_ARP
      scripts/config --module CONFIG_IP_NF_ARP_MANGLE
      scripts/config --module CONFIG_NFT_DUP_IPV6
      scripts/config --module CONFIG_NFT_FIB_IPV6
      scripts/config --module CONFIG_NF_TABLES_BRIDGE
      scripts/config --module CONFIG_NFT_BRIDGE_META
      scripts/config --module CONFIG_NFT_BRIDGE_REJECT
      scripts/config --module CONFIG_NET_ACT_CT
      scripts/config --module CONFIG_NFT_FLOW_OFFLOAD
      scripts/config --module CONFIG_NFT_FIB_INET
      scripts/config --module CONFIG_NFT_FIB_NETDEV
      scripts/config --module CONFIG_NF_FLOW_TABLE_INET

      # containerd
      scripts/config --enable CONFIG_CFS_BANDWIDTH

      # traefik
      scripts/config --enable CONFIG_NETFILTER_XT_MATCH_MULTIPORT

      # iscsi
      scripts/config --module CONFIG_ISCSI_TCP

      # metallb
      scripts/config --module CONFIG_NETFILTER_XT_MATCH_RECENT

      scripts/config --module CONFIG_CIFS
      scripts/config --enable CIFS_STATS2
      scripts/config --disable CIFS_ALLOW_INSECURE_LEGACY

      scripts/config --disable CIFS_UPCALL
      scripts/config --enable CIFS_XATTR
      scripts/config --enable CIFS_DEBUG
      scripts/config --enable CIFS_DEBUG2
      scripts/config --disable CIFS_DEBUG_DUMP_KEYS
      scripts/config --enable CIFS_DFS_UPCALL
      scripts/config --enable CIFS_SWN_UPCALL

      make oldconfig
    '';

    installPhase = ''
      cp .config $out
    '';
  };
  allowImportFromDerivation = true;
}
