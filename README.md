# Claims Registry

A claims registry is a way to store infomration about yourself or someone else. This is the base claims registry that can be used with platforms that require a DID solution. 

The current version of the registry is focused on offering first party claims. These are claims that a person makes about themself.

## Example Claim

```
 issuer: detroitpro_wallet_address
 subject: another_detroitpro_wallet_address
 key: wallet_name
 value: coffee_funds
```

## Example Username Claim

```
 issuer: detroitpro_wallet_address
 subject: another_detroitpro_wallet_address
 key: username
 value: detroitpro
```

# ERC165

- All ERC721 Contracts on the Akroma network should implement the ERC165 interface. 
- This example project implements the ERC165 interface.
- With the ERC165 interface implemented; contracts will show up in the block explorer.

# Deploying

`yarn deploy --network testnet`