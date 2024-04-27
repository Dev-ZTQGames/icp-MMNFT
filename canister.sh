dfx deploy --playground dip721_nft_container --argument "(
  principal \"pi5f5-wa6q7-y2zcs-4nqx7-veomh-k3rqy-bpii6-54d47-iix3c-hh3nx-pae\", 
  record {
    logo = record {
      logo_type = \"image/png\";
      data = \"\";
    };
    name = \"Mining Maze\";
    symbol = \"MM\";
    maxLimit = 10;
  }
)"
