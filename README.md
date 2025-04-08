# OddsHub Smart Contract

A decentralized prediction market platform built on Moonbeam that allows users to create and participate in various types of prediction markets.

## Overview

This smart contract implements a prediction market system where users can bet on the outcomes of different types of events:
- General markets (for various events)
- Sports markets (for sports events)
- Crypto markets (for cryptocurrency price movements)

The platform uses a simple market-making mechanism where users can buy shares in outcomes they believe will occur, and winners can claim proportional rewards from the pool.

## Features

- **Multiple Market Types**: Support for general, sports, and cryptocurrency prediction markets
- **Admin-controlled Market Creation**: Only admins can create new markets
- **Market Settlement**: Markets are settled by admins when the outcome is determined
- **User Positions**: Users can track their positions across all market types
- **Winnings Calculation**: Automatic calculation of rewards based on share ownership
- **Platform Fee**: A configurable platform fee (default 5%) is applied to all bets

## Contract Structure

The contract uses several key data structures:

### Core Structures

- `Outcome`: Represents a potential outcome of a market
- `Market`: Base market structure for general prediction markets
- `CryptoMarket`: Specialized market for cryptocurrency price predictions
- `SportsMarket`: Specialized market for sports event predictions
- `UserPosition`: Tracks a user's position in a market
- `UserBet`: Links a user's bet to a specific outcome
- `UserPositionsForMarket`: Comprehensive structure for user position information

## Functions

### Admin Functions

- `create_market`: Create a new general prediction market
- `create_crypto_market`: Create a new cryptocurrency prediction market
- `create_sports_market`: Create a new sports prediction market
- `settle_market`: Settle a general market with the winning outcome
- `settle_sports_market`: Settle a sports market with the winning outcome
- `settle_crypto_market_manually`: Manually settle a crypto market
- `toggle_market`: Activate or deactivate a market
- `set_treasury_wallet`: Update the treasury wallet address

### User Functions

- `buy_shares`: Buy shares in a specific outcome for a market
- `claim_winnings`: Claim rewards for a winning position
- `get_user_total_claimable`: View total claimable winnings across all markets

### View Functions

- `get_all_markets`: Get all general markets
- `get_all_sports_markets`: Get all sports markets
- `get_all_crypto_markets`: Get all crypto markets
- `get_user_markets`: Get all markets where a user has positions
- `get_user_sports_markets`: Get all sports markets where a user has positions
- `get_user_crypto_markets`: Get all crypto markets where a user has positions
- `get_user_positions_market`: Get comprehensive information about a user's positions

## Usage

### Deployment

To deploy the contract:

```solidity
constructor(address payable _treasuryWallet)
```

Requires a treasury wallet address where platform fees will be sent.

### Creating Markets

Only the admin can create markets:

```solidity
// Create a general market
create_market(
    string memory name, 
    string memory description,
    string memory outcome1,
    string memory outcome2,
    string memory category,
    string memory image,
    uint64 deadline
)

// Create a crypto market
create_crypto_market(
    string memory name, 
    string memory description,
    string memory outcome1,
    string memory outcome2,
    string memory category,
    string memory image,
    uint64 deadline,
    uint8 conditions,
    uint64 priceKey,
    uint128 amount
)

// Create a sports market
create_sports_market(
    string memory name, 
    string memory description,
    string memory outcome1,
    string memory outcome2,
    string memory category,
    string memory image,
    uint64 deadline,
    uint64 api_event_id,
    bool is_home
)
```

### Participating in Markets

Users can participate by buying shares in outcomes:

```solidity
buy_shares(
    uint256 market_id,
    uint8 token_to_mint,
    uint8 market_type
) payable
```

### Claiming Winnings

Winners can claim their rewards after the market is settled:

```solidity
claim_winnings(
    uint256 market_id,
    uint8 market_type,
    uint8 bet_num
)
```

## Security Considerations

- The contract includes checks for market expiration, settlement status, and active status
- Only the admin can create markets and settle outcomes
- The contract uses proper security checks for user claim validations
- Funds are handled safely with appropriate checks

## Development and Testing

The contract uses Hardhat for development and testing. It imports OpenZeppelin libraries for security and standardization.

## License

This project is licensed under the MIT License.
