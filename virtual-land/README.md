# Virtual Land Smart Contract

A Clarity smart contract for managing ownership and transactions of virtual land parcels on the Stacks blockchain.

## Overview

This project implements a virtual land ownership system where users can:
- Mint new virtual land parcels (admin only)
- Buy available land parcels
- List owned land for sale
- Transfer ownership through purchases

## Project Structure

```
virtual-land/
├── contracts/
│   └── virtual-land.clar     # Main contract logic
├── tests/
│   └── virtual-land_test.clar  # Contract tests
├── Clarinet.toml             # Project configuration
├── README.md                 # This file
└── .gitignore                # Git ignore file
```

## Contract Functions

### Initialize
Sets the contract deployer as the owner.
```clarity
(define-public (initialize))
```

### Mint Land
Creates a new land parcel with a specified ID and price. Only the contract owner can mint new land.
```clarity
(define-public (mint-land (land-id uint) (price uint)))
```

### Buy Land
Allows users to purchase land parcels that are listed for sale.
```clarity
(define-public (buy-land (land-id uint)))
```

### List Land for Sale
Enables land owners to list their parcels for sale at a specified price.
```clarity
(define-public (list-land (land-id uint) (price uint)))
```

## Error Codes

- `u100`: Contract already initialized
- `u101`: Unauthorized to mint land (not owner)
- `u102`: Land not for sale or insufficient funds
- `u103`: Land ID not found
- `u104`: Not authorized to list land (not owner)
- `u105`: Land ID not found when listing

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

2. Deploy using the Stacks CLI (testnet example)
   ```bash
   stx deploy_contract -t --config=/path/to/config.toml virtual-land /path/to/virtual-land.clar
   ```

## Future Enhancements

- Land metadata support
- Royalty payments on secondary sales
- Multi-token payment options
- Land parcel merging/subdivision

## License

[MIT License](LICENSE)
