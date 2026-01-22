{ ... }:

{
  #TODO: add root keys
  ssh = {
    groups = rec {
      dcurgz = [ 
        ./ssh/airberry/host_ed25519.pub
        ./ssh/airberry/dcurgz_ed25519.pub
        ./ssh/hyperberry/host_ed25519.pub
        ./ssh/hyperberry/dcurgz_ed25519.pub
        ./ssh/blueberry/host_ed25519.pub
        ./ssh/blueberry/dcurgz_ed25519.pub
        ./ssh/swiss/id_ed25519.pub
      ];

      wg = [
        ./ssh/miniberry/dcurgz_ed25519.pub
        ./ssh/piberry/piberry_ed25519.pub
        ./ssh/piberry/host_ed25519.pub
      ];

      privileged = dcurgz;
    };

    airberry = [
      ./ssh/airberry/dcurgz_ed25519.pub
      ./ssh/airberry/host_ed25519.pub
    ];

    hyperberry = [
      ./ssh/hyperberry/dcurgz_ed25519.pub
      ./ssh/hyperberry/host_ed25519.pub
    ];

    blueberry = [
      ./ssh/blueberry/dcurgz_ed25519.pub
      ./ssh/blueberry/host_ed25519.pub
    ];

    miniberry = [
      ./ssh/miniberry/dcurgz_ed25519.pub
    ];

    piberry = [
      ./ssh/piberry/piberry_ed25519.pub
      ./ssh/piberry/host_ed25519.pub
    ];
  };

  gpg = {
    groups = rec {
      dcurgz = [
        ./gpg/dcurgz.asc
        ./gpg/airberry.asc
        ./gpg/blueberry.asc
        ./gpg/hyperberry.asc
        ./gpg/swiss.asc
      ];

      wg = [
        ./gpg/miniberry.asc
        #./gpg/piberry.asc
      ];

      privileged = dcurgz;
    };

    airberry = [ ./gpg/airberry.asc ];
    hyperberry = [ ./gpg/hyperberry.asc ];
    blueberry = [ ./gpg/blueberry.asc ];
    miniberry = [ ./gpg/miniberry.asc ];
    piberry = [ ./gpg/piberry.asc ];
  };
}
