# Virtual Land Smart Contract - Phase 2

A Clarity smart contract ecosystem for managing ownership, transactions, and metadata of virtual land parcels on the Stacks blockchain.

## Overview

This project implements a comprehensive virtual land ownership system where users can:
- Mint new virtual land parcels (admin only)
- Buy and sell land parcels
- List owned land for sale
- Transfer ownership through purchases
- Rent land to other users
- Register and retrieve land metadata
- Benefit from owning adjacent land parcels

## Project Structure

```
virtual-land/
├── contracts/
│   ├── virtual-land.clar           # Main contract logic for ownership and transactions
│   └── virtual-land-registry.clar  # Contract for land metadata and attributes
├── tests/
│   ├── virtual-land_test.clar      # Contract tests for main functionality
│   └── virtual-land-registry_test.clar # Tests for registry functionality
├── Clarinet.toml                   # Project configuration
├── README.md                       # This file
└── .gitignore                      # Git ignore file
```

## Contract Functions

### Virtual Land Contract

#### Core Functions
- **Initialize**: Sets the contract deployer as the owner
```clarity
(define-public (initialize))
```

- **Mint Land**: Creates a new land parcel (owner only)
```clarity
(define-public (mint-land (land-id uint) (price uint)))
```

- **Buy Land**: Purchase land parcels listed for sale
```clarity
(define-public (buy-land (land-id uint)))
```

- **List Land for Sale**: List owned parcels for sale
```clarity
(define-public (list-land (land-id uint) (price uint)))
```

#### New Phase 2 Functions
- **Rent Land**: Create a rental agreement for a land parcel
```clarity
(define-public (rent-land (land-id uint) (tenant principal) (duration uint) (price uint)))
```

- **Accept Rental**: Accept and pay for a rental agreement
```clarity
(define-public (accept-rental (land-id uint)))
```

- **Ownership Verification**: Check if a user owns a specific land parcel
```clarity
(define-read-only (is-land-owner (land-id uint) (user principal)))
```

- **Adjacent Land Check**: Check if a user owns adjacent land parcels
```clarity
(define-read-only (owns-adjacent-lands (land-id uint) (user principal)))
```

#### Security Functions
- **Pause Contract**: Emergency pause for contract operations (admin only)
```clarity
(define-public (pause-contract))
```

- **Resume Contract**: Resume contract operations after pause (admin only)
```clarity
(define-public (resume-contract))
```

### Virtual Land Registry Contract

- **Register Metadata**: Add metadata to a land parcel (owner only)
```clarity
(define-public (register-metadata (land-id uint) (name (string-ascii 50)) (description (string-ascii 256)) (x int) (y int) (features (list 10 (string-ascii 50)))))
```

- **Get Metadata**: Retrieve metadata for a land parcel
```clarity
(define-read-only (get-metadata (land-id uint)))
```

## Error Codes

### Virtual Land Contract
- `u100`: Contract already initialized
- `u101`: Unauthorized to mint land (not owner)
- `u102`: Land not for sale or insufficient funds
- `u103`: Land ID not found
- `u104`: Not authorized to list land (not owner)
- `u105`: Land ID not found when listing
- `u106`: Not the owner of the land for rental
- `u107`: Not the tenant or rental expired
- `u108`: Rental agreement not found
- `u110`: Not authorized for administrative function
- `u111`: Contract is paused
- `u112`: Reentrancy detected

### Virtual Land Registry Contract
- `u201`: Not the land owner

## Security Improvements in Phase 2

1. **Payment Processing Fixed**: Implemented proper STX token transfers during land purchases
2. **Contract Pause Mechanism**: Added emergency pause functionality to freeze operations
3. **Input Validation**: Added validation for parameters like price
4. **Non-reentrancy Guard**: Implemented protection against reentrancy attacks
5. **Owner Verification**: Added explicit verification of land ownership

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- Node.js and NPM (for testing and deployment tools)

### Installation

1. Clone this repository
   ```bash
   git clone https://github.com/midorichie/virtual-land.git
   cd virtual-land
   ```

2. Install Clarinet (if not already installed)
   ```bash
   npm install -g @hirosystems/clarinet
   ```

3. Start the development environment
   ```bash
   clarinet console
   ```

### Testing

Run the included tests to verify contract functionality:
```bash
clarinet test
```

## Deployment

To deploy this contract to the Stacks blockchain:

1. Build the project
   ```bash
   clarinet build
   ```

2. Deploy the contracts using the Stacks CLI (testnet example)
   ```bash
   stx deploy_contract -t --config=/path/to/config.toml virtual-land /path/to/virtual-land.clar
   stx deploy_contract -t --config=/path/to/config.toml virtual-land-registry /path/to/virtual-land-registry.clar
   ```

## Future Enhancements

- Land parcel subdividing and merging
- Token gating for exclusive land access
- Community governance for land zones
- Integration with NFT standards for land representation
- Marketplace fees and creator royalties
- Land development and improvement mechanics

## License

[MIT License](LICENSE)
