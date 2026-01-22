{ pkgs }:

pkgs.linkFarmFromDrvs "mods" (
  builtins.attrValues {
    "3dskinlayers" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/zV5r3pPn/versions/yjqaUIff/skinlayers3d-fabric-1.8.0-mc1.20.1.jar";
      sha512 = "41099cab21f833feb203cf31dfb78d39209c9cfebbee6f5492377f0d7e9ed8c4c665aa5f057836bdfd80fbc7b88e442863452356c9a5a1a1ec8b24553ce95d1c";
    };
    appleskin = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/xcauwnEB/appleskin-fabric-mc1.20.1-2.5.1.jar";
      sha512 = "1544c3705133694a886233bdf75b0d03c9ab489421c1f9f30e51d8dd9f4dcab5826edbef4b7d477b81ac995253c6258844579a54243422b73446f6fb8653b979";
    };
    bclib = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/BgNRHReB/versions/TPC86Pyz/bclib-3.0.14.jar";
      sha512 = "bc35cc37a221fbc6f7fca293e72aad0877d8c9d07067ff0b4c8f51dcddbb82ac7cbbb86d1550eef7690bcd1ecf09625f0389f39ae9a252eec5d8511ba7deec4a";
    };
    betterend = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/gc8OEnCC/versions/7QwyTILr/better-end-4.0.11.jar";
      sha512 = "5faae5cb3d8759837ec341c605dd9c8b6b32a908e7e1f1248b3b2567c5f9969079df33694cdfb6c743a732bfc9d5824843a93edec07f09e68f8b408e355d15e7";
    };
    betterendcitiesbetterend = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/DlcfxdlN/versions/PsRaK3Nh/better-end-cities-better-end-1.0.0.jar";
      sha512 = "8cf42fd442e4ab6815b9862a4e3aacbd81612fd952528524af909064ebd70de8a479009d198a019450cd55ec9181198520536e2fa74952c2f903c3a03489f0e8";
    };
    betternether = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/MpzVLzy5/versions/IG7kgtJH/better-nether-9.0.10.jar";
      sha512 = "0ef96b8409904c0ce1b9a875260f252615d7b46704082cfd10ffee88d2d506984ad0c31a91e5cb3392f454bc646b7676c392ac94d78474f156aa519f9501f3d0";
    };
    betterf3 = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/8shC1gFX/versions/7WkFnw9F/BetterF3-7.0.2-Fabric-1.20.1.jar";
      sha512 = "1b1f5bae45050bf01a23c57cfe94b7f42c6e0e9d669150effc04d3d09fd43c2dbea6c634117309ab1ee11253fcdb3c6061a9034e963b7f08476a76f1e98c3b8a";
    };
    bookshelf = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uy4Cnpcm/versions/CBnLZwRS/Bookshelf-Fabric-1.20.1-20.2.13.jar";
      sha512 = "6cc0536833c4f1922711da91c3baf3a79b4bf8c72aa548a34e8f4852fc9b1cb51f21729c58544fbe05909fd3e1da316d1f885033af5844024cea936c3626e3d2";
    };
    cicada = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/IwCkru1D/versions/V4Hke1bi/cicada-lib-0.13.0%2B1.20.1.jar";
      sha512 = "68be831e6bb9f3370a34fceb2aea38387c6221d51a6c774e4d02df94ba3e233800e07a17f2c73592b808f904f82d5b6188978f36085451649708069cffa909d5";
    };
    clothconfigv11 = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/9s6osm5g/versions/2xQdCMyG/cloth-config-11.1.136-fabric.jar";
      sha512 = "2da85c071c854223cc30c8e46794391b77e53f28ecdbbde59dc83b3dbbdfc74be9e68da9ed464e7f98b4361033899ba4f681ebff1f35edc2c60e599a59796f1c";
    };
    clumps = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/hefSwtn6/Clumps-fabric-1.20.1-12.0.0.4.jar";
      sha512 = "2235d29b1239d5526035bffd547d35fe33b9e737d3e75cd341f6689d9cd834d0a7dc03ed80748772162cd9595ba08e7a0ab51221bc145a8fd979d596c3967544";
    };
    combatlog = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/nNnLt4Jb/versions/raRiYCvk/combatlog-2.4%2B1.20.jar";
      sha512 = "c1aba6ca4b3a42e9cc83bdbf7c650479f4df47dd9f63d04c8d096b20ead205e41ca65990272b59dc5a7637baad0c8bd868d6b9ea8c99834b0c4c803f51bd0d66";
    };
    continuity = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/1IjD5062/versions/qGTDcjHM/continuity-3.0.0%2B1.20.1.jar";
      sha512 = "7205cae3c534fd5d5328a9659146911381c06e54da995aabd11745ad72def5bd5120b7cb792fab2e8dcaa4670c23bdba21079b8f6da94152cfc6ea4b415edcbf";
    };
    controllingforfabric = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/xv94TkTM/versions/6ipZLQSK/Controlling-fabric-1.20.1-12.0.2.jar";
      sha512 = "1e3da9b2b50488daa7b9165930a48158330404110912037cf42543c6acf649ad79019a324ee42e5ef88ad51bb64ee40684a147bfb7847412259b7cebff0134ee";
    };
    deimos = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/WQaxNzFg/versions/iUVAo3IR/deimos-1.20.1-fabric-2.2.jar";
      sha512 = "ef286c8c52e70d49fa32b0825ee78e45ec0abe002a3a979aec32ccf90afb8e1dd89c5d9cb9ff392c706c947fbbd20821aa29434796b4a1ba1f787ddafe0c025b";
    };
    distanthorizons = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uCdwusMi/versions/vSDePnsB/DistantHorizons-fabric-forge-2.3.2-b-1.20.1.jar";
      sha512 = "14f5548cffa24fabdcfce6626fc813db42e28350a126833a54e1c54e13e6b393e232b5a0d55fe6bc6f7e273061adaade67f8a8bbee9503cdaf869c28db0995b7";
    };
    doabarrelroll = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/6FtRfnLg/versions/CuLlUIYD/do_a_barrel_roll-fabric-3.6.1%2B1.20.1.jar";
      sha512 = "e2294aeb8589c5a0c7508a0b5ac575bc47f05fbf85db50c985f5165f9ee29292a0f8ee8d548083b151af0a9c843e4ec68d6ca8f1861c91f6b9446269190bf662";
    };
    elytraslot = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/mSQF1NpT/versions/7w60aZYA/elytraslot-fabric-6.4.4%2B1.20.1.jar";
      sha512 = "4ffb63737c7cf209443d9026b60467136b437ea207986f32e2caef1305fa4b3aaa907844a3e647f4d3c54b683b22e0cf26ddd3c83a6da01b5a3e8a2cf8afcec5";
    };
    elytratrims = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/XpzGz7KD/versions/swlgoemm/elytratrims-fabric-3.5.9%2B1.20.1.jar";
      sha512 = "2b7d9c2126749dabf1aba6bebb156c315cbc0fdc6756a7aa58685511f62a52ecffddbab8c3015f514b8bb6395946f7be5b2dc8f04c44d715e372ec255153e977";
    };
    enchantmentdescriptions = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/UVtY3ZAC/versions/LeAiyr1s/EnchantmentDescriptions-Fabric-1.20.1-17.1.19.jar";
      sha512 = "9ba8a939713b7945b937118b756033e1428b3b445c60276e3e6143d95a6a5f839ebc95233290cd34fed953000301d5f24b4f680fb53ebd85587c73e8e27b5682";
    };
    fabricapi = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/UapVHwiP/fabric-api-0.92.6%2B1.20.1.jar";
      sha512 = "2bd2ed0cee22305b7ff49597c103a57c8fbe5f64be54a906796d48b589862626c951ff4cbf5cb1ed764a4d6479d69c3077594e693b7a291240eeea2bb3132b0c";
    };
    fabriclanguagekotlin = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/mccDBWqV/fabric-language-kotlin-1.13.4%2Bkotlin.2.2.0.jar";
      sha512 = "26b6b4499bf872ebc2c666227b2ed721ce0e33a8e8b19632971250e5cb6e0b9f35aef15a07ce53cf4755285d9d38c4e05a5f1357bad544d44b9e30b87c0a0055";
    };
    fallingleaves = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/WhbRG4iK/versions/flPXaySR/fallingleaves-1.15.6%2B1.20.1.jar";
      sha512 = "9a335ccb81b4511c073dc4cc687a4bdbeb2aec5f8735da6032096d13e90a81b98912dd96cafed885ea4b9d30d5e44fa4d2dda185009164b285f297f021da4e78";
    };
    flatexpcosts = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/rN9rp7X0/versions/zRaQbe1K/consistentexpcost-1.20.1-fabric-0.1.jar";
      sha512 = "5c14e60296dcd651ddf9d5ceb24876e2b7a6606c4a1ac6b63168c98b27e4d1f3dbc65ef03c796d711e520219d7b494b2933dc982342d61c76de2f804d820cd57";
    };
    geckolib4 = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/ezKSGafs/geckolib-fabric-1.20.1-4.7.2.jar";
      sha512 = "22e7e59f4c708f927f0e7c17e92491a25bb233ecfc6993b6f01d7f6c1a9fe0e88eb1f0a5f019a1bc1d60095a77b88be903e7e5b0132e214d43c5ba28087f00f7";
    };
    indium = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Orvt0mRa/versions/nQHYSjxO/indium-1.0.36%2Bmc1.20.1.jar";
      sha512 = "7c5a1851f1fc08ae69318e151d07151fabba6cda2a24616c9251e1a4e5b969453e88b97d60f926271d60e3511bfc6fa05a64a108466efb7f29bec4519547e0c9";
    };
    jade = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/drol2x1P/Jade-1.20-Fabric-11.13.1.jar";
      sha512 = "048029727a30462abc8e43ecae2d5178ab653783c6dbcb2bd7c4c9cc1bb7c7a2ad5267ca3f89757f5b716da3f653b8e60ed8f46497917f26f094acc8f7dd7dc9";
    };
    justenoughitems = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/MMnbcAih/jei-1.20.1-fabric-15.20.0.112.jar";
      sha512 = "c13fbab6764aec7f8f29eace23592aeabaf2adf1aa03af73e996aeceb2d553485fa94b6162874464bb3ab41e70f3448ed2c42553eecbcaefa682f0fa015dcae4";
    };
    kaffeesdualride = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/dv1QW2PN/versions/yXe8QjGL/Kaffee%27s_Dual_Ride-mc1.20.1-1.1.0.jar";
      sha512 = "4b6fefdaa7f2b2ca443b9389be08533608b529b13e1a3cf9d4a758e288c511b319df0d86a0a42b3c25619ac3530921d46351e0e7e4132999c82c2b1a7aa7f667";
    };
    lithium = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/vuuAe7ZA/lithium-fabric-mc1.20.1-0.11.3.jar";
      sha512 = "dc9bc65146f41cf99c46b46216dd3645be7c45cfeb2bc7cdceaa11bcd57771cdf2c30e84ce057f12b8dbf0d54fb808143cf46d92626370011ba5112bec18e720";
    };
    modmenu = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/mOgUt4GM/versions/lEkperf6/modmenu-7.2.2.jar";
      sha512 = "9a7837e04bb34376611b207a3b20e5fe1c82a4822b42929d5b410809ec4b88ff3cac8821c4568f880775bafa3c079dfc7800f8471356a4046248b12607e855eb";
    };
    mousetweaks = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/aC3cM3Vq/versions/mjuG4AYd/MouseTweaks-fabric-mc1.20-2.26.jar";
      sha512 = "d0faf200dda358efddad2d2809f646023f4dd06254572369e07f3bf33cb6941f0fcdb02db4675b30b4f3bd542cbf6196e135680ba91a2b74c2b071f34978e2d5";
    };
    notenoughanimations = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/MPCX6s5C/versions/JDsPJFGx/notenoughanimations-fabric-1.10.0-mc1.20.1.jar";
      sha512 = "babd1820826fa154082c9c2a34ebb968b8b9e6b8573f0b7467771906a1c640a426aa549f748672b74184155e6541e6b91b365cc882beda63f6c44bff3d29618a";
    };
    pingwheel = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/QQXAdCzh/versions/57oiW0gw/Ping-Wheel-1.10.3-fabric-1.20.1.jar";
      sha512 = "e50ab2be4f05e9d621a98c3994a9b20254eca6ca06715dc05c187e9fb9eff9f17ad2d6b334e2be627d37faddbe13886a5037e0be8148cd9a54fb7a5803d5b09c";
    };
    searchables = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/fuuu3xnx/versions/eh4IBlu2/Searchables-fabric-1.20.1-1.0.3.jar";
      sha512 = "94a44b9ad58507a28ffb6e1a48b28b23740d4192c5511012b0eb8db33360200232ec84ceba121368fa3e54d1b845458434950ad1f6702d0e8ad5746843480bf3";
    };

    simplevoicechat = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/paqCYLFD/voicechat-fabric-1.20.1-2.5.32.jar";
      sha512 = "cb524ed2606070a2f1e1de6872c5bdba57788591bc97d07fa582bbe3c499ffc79c2b5d70af2c3f92d0fd8dfc3b2cee2ba1ce2940dcaffe4b624614029dea4024";
    };
    terrablender = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/J1S3aA8i/TerraBlender-fabric-1.20.1-3.0.1.10.jar";
      sha512 = "a2d5edbe9df43185e9c83ab426cbcda4b1d0537d9ede8be630d6d650e04d5decf574ef59cbc163913255b57784fa906d26557471fc698e0f27ceee2a1ec41ed9";
    };
    trinkets = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/5aaWibi9/versions/AHxQGtuC/trinkets-3.7.2.jar";
      sha512 = "bedf97c87c5e556416410267108ad358b32806448be24ef8ae1a79ac63b78b48b9c851c00c845b8aedfc7805601385420716b9e65326fdab21340e8ba3cc4274";
    };
    xaerosminimap = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/1bokaNcj/versions/ePRxT2Wj/Xaeros_Minimap_25.2.6_Fabric_1.20.jar";
      sha512 = "eca26f5dda06a5c42a8790261a37e894c650e77aa2b51ca6f201a967dcbc61856971c68db65ffb6295ac2651e12a00d9bac1d8b9133c8e9ce67dfbdd1b786b0e";
    };
    xaerosworldmap = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/NcUtCpym/versions/fQpXYWtL/XaerosWorldMap_1.39.9_Fabric_1.20.jar";
      sha512 = "d10acb6ba4fa104372ad98baff2734bd98622ab3396a751a77c204efd349b73bf4044af4c65a62e92cbe14ee073d5424e1985776e4310968037e84543e336705";
    };
    yungsapi = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Ua7DFN59/versions/lscV1N5k/YungsApi-1.20-Fabric-4.0.6.jar";
      sha512 = "90fea70f21cd09bdeefe9cb6bd23677595b32156b1b8053611449504ba84a21ee1e13e5a620851299090ce989f41b97b9b4bdc98def1ccecb33115e19553c64e";
    };
    yungsbetterdeserttemples = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/XNlO7sBv/versions/1Z9HNWpj/YungsBetterDesertTemples-1.20-Fabric-3.0.3.jar";
      sha512 = "29839615e042435b0fdacab2b97524a6689190692a289c25e305dbaec34764f38e70c65cfd77b49ac0dcc549281b61cfe244edc62809082e39db54990ef84cbf";
    };
    yungsbetterdungeons = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/o1C1Dkj5/versions/nidyvq2m/YungsBetterDungeons-1.20-Fabric-4.0.4.jar";
      sha512 = "02ee00641aea2e80806923c1d97a366b82eb6d6e1d749fc8fb4eeddeddea718c08f5a87ba5189427f747801b899abe5a6138a260c7e7f949e5e69b4065ac5464";
    };
    yungsbetterendisland = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/2BwBOmBQ/versions/qJTsmyiE/YungsBetterEndIsland-1.20-Fabric-2.0.6.jar";
      sha512 = "cb63d9cdd69f955ed8044aec6f03aedbf76fdb53fd97826b254b68e3559941df301b714260505d165c58c276aa7ea7c11c2fada7509cb731f10b1815d5633b87";
    };
    yungsbetterjungletemples = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/z9Ve58Ih/versions/6LPrzuB0/YungsBetterJungleTemples-1.20-Fabric-2.0.5.jar";
      sha512 = "ea08ade714376f48cabdddd2e4b7376fc5cc5947e3911583ba4e182ab22c1335c884043441725cde21fb6e84402d17c43f509ade339d46a1a1db40f0e77ee81a";
    };
    yungsbettermineshafts = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/HjmxVlSr/versions/qLnQnqXS/YungsBetterMineshafts-1.20-Fabric-4.0.4.jar";
      sha512 = "82d6e361ef403471beaaf2fa86964af541df167da56f53b820e5abfac693f63dd5d6c0aafbc9e9baa947b42a57c79f069ed6ede55e680a2523d2ca7f2e538b13";
    };
    yungsbetternetherfortresses = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Z2mXHnxP/versions/FL88RLRu/YungsBetterNetherFortresses-1.20-Fabric-2.0.6.jar";
      sha512 = "a752f0dea20fa86e6d3a4f87d180af706b2ad5e3d434185aaa624692fc55329a2e2e410e67f843ec982e7b90ae63565b4aed43adbee6c50ded403ef50d91d7fd";
    };
    yungsbetteroceanmonuments = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/cs7iGVq1/versions/8h469FpE/YungsCaveBiomes-1.20.1-Fabric-2.0.5.jar";
      sha512 = "02e689eb98ddd8390f1853751891addb4e0888ce35682ab12e565dba842d999d494284ac7423783ab10c333d1888284ca30a7e21d358e5a5002b1bb8086af37d";
    };
    yetanotherconfiglib = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/1eAoo2KR/versions/dvS5DjUA/yet_another_config_lib_v3-3.6.6%2B1.20.1-fabric.jar";
      sha512 = "20f282b3cdaec7c83a96840edb756336677c5816ed943145022f1ce1eafac0c9aa7c621939e15abe6f4309626738bc56d3d1b8434f5175d22e7409108630b02b";
    };
    zoomify = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/w7ThoJFB/versions/VsZyF8DS/Zoomify-2.14.4%2B1.20.1.jar";
      sha512 = "89ac40fd2bf8fe36725c6fefbf670e8fec39a2775b5615b007492bcbd0a06ba5ee1409b630a82c3fb09819a7f05cdb54f4c4091f56902f391c74885abee31202";
    };
  }
)
