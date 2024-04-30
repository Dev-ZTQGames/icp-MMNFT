import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Types "./Types";

shared actor class Dip721NFT(custodian: Principal, init : Types.Dip721NonFungibleToken) = Self {
  stable var transactionId: Types.TransactionId = 0;
  stable var nfts = List.nil<Types.Nft>();
  stable var nfts_Limit : Nat64 = 5555;
  stable var nftsRare = List.nil<Types.Nft>();
  stable var nftsRare_Limit : Nat64 = 2222;
  stable var nftsEpic = List.nil<Types.Nft>();
  stable var nftsEpic_Limit : Nat64 = 1111;
  stable var nftsUnique = List.nil<Types.Nft>();
  stable var nftsUnique_Limit : Nat64 = 555;
  stable var nftsLegendary = List.nil<Types.Nft>();
  stable var nftsLegendary_Limit : Nat64 = 111;
  stable var custodians = List.make<Principal>(custodian);
  stable var logo : Types.LogoResult = init.logo;
  stable var name : Text = init.name;
  stable var symbol : Text = init.symbol;
  stable var maxLimit : Nat16 = init.maxLimit;

  stable var baseURL : Text = "https://cdn.aurorahunt.xyz/nft/mm/";

  // https://forum.dfinity.org/t/is-there-any-address-0-equivalent-at-dfinity-motoko/5445/3
  let null_address : Principal = Principal.fromText("aaaaa-aa");

  public query func balanceOfDip721(user: Principal) : async Nat64 {
    return Nat64.fromNat(
      List.size(
        List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == user }) + 
	List.filter(nftsRare, func(token: Types.Nft) : Bool { token.owner == user }) + 
	List.filter(nftsEpic, func(token: Types.Nft) : Bool { token.owner == user }) + 
	List.filter(nftsUnique, func(token: Types.Nft) : Bool { token.owner == user }) + 
	List.filter(nftsLegendary, func(token: Types.Nft) : Bool { token.owner == user })
      )
    );
  };

  public query func ownerOfDip721(token_id: Types.TokenId) : async Types.OwnerResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case (null) {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok(token.owner);
      };
    };
  };

  public shared({ caller }) func safeTransferFromDip721(from: Principal, to: Principal, token_id: Types.TokenId) : async Types.TxReceipt {  
    if (to == null_address) {
      return #Err(#ZeroAddress);
    } else {
      return transferFrom(from, to, token_id, caller);
    };
  };

  public shared({ caller }) func transferFromDip721(from: Principal, to: Principal, token_id: Types.TokenId) : async Types.TxReceipt {
    return transferFrom(from, to, token_id, caller);
  };

  func transferFrom(from: Principal, to: Principal, token_id: Types.TokenId, caller: Principal) : Types.TxReceipt {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        if ( caller != token.owner and not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller }) ) {
          return #Err(#Unauthorized);
        } else if (Principal.notEqual(from, token.owner)) {
          return #Err(#Other);
        } else {
          nfts := List.map(nfts, func (item : Types.Nft) : Types.Nft {
            if (item.id == token.id) {
              let update : Types.Nft = {
                owner = to;
                id = item.id;
                metadata = token.metadata;
              };
              return update;
            } else {
              return item;
            };
          });
          transactionId += 1;
          return #Ok(transactionId);   
        };
      };
    };
  };

  public query func supportedInterfacesDip721() : async [Types.InterfaceId] {
    return [#TransferNotification, #Burn, #Mint];
  };

  public query func logoDip721() : async Types.LogoResult {
    return logo;
  };

  public query func nameDip721() : async Text {
    return name;
  };

  public query func symbolDip721() : async Text {
    return symbol;
  };

  public query func baseURLCustom() : async Text {
    return baseURL;
  };

  public query func totalSupplyDip721() : async Nat64 {
    return Nat64.fromNat(
      List.size(nfts) + List.size(nftsRare) + List.size(nftsEpic) + List.size(nftsUnique) + List.size(nftsLegendary)
    );
  };

  public query func totalSupplyNormalCustom() : async Nat64 {
    return Nat64.fromNat(
      List.size(nfts)
    );
  };

  public query func totalSupplyRareCustom() : async Nat64 {
    return Nat64.fromNat(
      List.size(nftsRare)
    );
  };

  public query func totalSupplyEpicCustom() : async Nat64 {
    return Nat64.fromNat(
      List.size(nftsEpic)
    );
  };

  public query func totalSupplyUniqueCustom() : async Nat64 {
    return Nat64.fromNat(
      List.size(nftsUnique)
    );
  };

  public query func totalSupplyLegendaryCustom() : async Nat64 {
    return Nat64.fromNat(
      List.size(nftsLegendary)
    );
  };

  public query func getMetadataDip721(token_id: Types.TokenId) : async Types.MetadataResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok(token.metadata);
      };
    };
  };

  public query func getMaxLimitDip721() : async Nat16 {
    return maxLimit;
  };

  public func setBaseURLCustom(url: Text) : async Text {
    baseURL := url;
    return baseURL;
  };

  public func getMetadataForUserDip721(user: Principal) : async Types.ExtendedMetadataResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    switch (item) {
      case null {
        return #Err(#Other);
      };
      case (?token) {
        return #Ok({
          metadata_desc = token.metadata;
          token_id = token.id;
        });
      };
    };
  };

  public query func getTokenIdsForUserDip721(user: Principal) : async [Types.TokenId] {
    let items = List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    let tokenIds = List.map(items, func (item : Types.Nft) : Types.TokenId { item.id });
    return List.toArray(tokenIds);
  };

  public shared({ caller }) func mintDip721(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {

    let newId = Nat64.fromNat(List.size(nfts));

    if ( newId + 1 > nfts_Limit ) {
      return #Err(#ExceedLimit);
    };

    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nfts := List.push(nft, nfts);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller }) func mintRareCustom(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {
  
    let newId = Nat64.fromNat(List.size(nftsRare));

    if ( newId + 1 > nftsRare_Limit ) {
      return #Err(#ExceedLimit);
    };

    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.owner == to });
    if ( item == null ) {
        return #Err(#Unauthorized);
    };

    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nftsRare := List.push(nft, nftsRare);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller }) func mintEpicCustom(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {

    let newId = Nat64.fromNat(List.size(nftsEpic));

    if ( newId + 1 > nftsEpic_Limit ) {
      return #Err(#ExceedLimit);
    };

    let item = List.find(nftsRare, func(token: Types.Nft) : Bool { token.owner == to });
    if ( item == null ) {
        return #Err(#Unauthorized);
    };

    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nftsEpic := List.push(nft, nftsEpic);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller }) func mintUniqueCustom(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {

    let newId = Nat64.fromNat(List.size(nftsUnique));

    if ( newId + 1 > nftsUnique_Limit ) {
      return #Err(#ExceedLimit);
    };

    let item = List.find(nftsEpic, func(token: Types.Nft) : Bool { token.owner == to });
    if ( item == null ) {
        return #Err(#Unauthorized);
    };

    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nftsUnique := List.push(nft, nftsUnique);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller }) func mintLegendaryCustom(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {

    let newId = Nat64.fromNat(List.size(nftsLegendary));

    if ( newId + 1 > nftsLegendary_Limit ) {
      return #Err(#ExceedLimit);
    };

    let item = List.find(nftsUnique, func(token: Types.Nft) : Bool { token.owner == to });
    if ( item == null ) {
        return #Err(#Unauthorized);
    };

    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nftsLegendary := List.push(nft, nftsLegendary);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };
}
