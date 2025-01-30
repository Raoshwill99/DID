# Reputation-Based Decentralized Identity Credit Scoring System

## Overview
A decentralized identity (DID) system built on the Stacks blockchain that calculates and manages credit scores based on users' on-chain activity, transaction history, and reputation. This system enables users to maintain sovereignty over their financial identity while providing verifiable creditworthiness data to potential lenders and business partners.

## Features
- Decentralized credit score calculation and storage
- Privacy-preserving identity verification
- On-chain transaction history tracking
- Selective disclosure of credit information
- Business integration endpoints

## Technical Architecture

### Smart Contracts
The system consists of the following core components:

1. **UserScores Map**
   - Stores user credit scores
   - Tracks verification status
   - Maintains update history

2. **UserTransactions Map**
   - Records transaction outcomes
   - Tracks transaction volumes
   - Maintains success/failure ratios

### Key Functions

#### Public Functions
- `initialize-user`: Creates new user profile with base score
- `update-transaction-history`: Updates user transaction records
- `get-credit-score`: Retrieves user credit score
- `get-transaction-history`: Fetches transaction history

#### Administrative Functions
- `verify-user`: Verifies user identity status

## Getting Started

### Prerequisites
- Stacks blockchain environment
- Clarity CLI tools
- Rust development environment

### Installation
1. Clone the repository:
```bash
git clone [repository-url]
cd reputation-did-system
```

2. Install dependencies:
```bash
clarinet install
```

3. Run tests:
```bash
clarinet test
```

### Deployment
1. Configure your Stacks wallet
2. Update deployment settings in `Clarinet.toml`
3. Deploy using Clarinet:
```bash
clarinet deploy
```

## Usage

### Initializing a User Profile
```clarity
(contract-call? .credit-score-system initialize-user)
```

### Updating Transaction History
```clarity
(contract-call? .credit-score-system update-transaction-history true u1000)
```

### Checking Credit Score
```clarity
(contract-call? .credit-score-system get-credit-score tx-sender)
```

## Security Considerations
- All sensitive user data is stored on-chain in a privacy-preserving manner
- Administrative functions are protected by ownership checks
- Transaction history is immutable and verifiable
- Score calculations are transparent and auditable

## Development Roadmap

### Phase 1 (Current)
- Basic credit score system
- Transaction tracking
- User verification

### Future Phases
- Enhanced scoring algorithm
- Privacy features
- Business integration API
- Mobile app integration
- Cross-chain compatibility

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
- Project Maintainer: Adigun Rasheed Olayinka
- Email: adigun_olami99@yahoo.com

## Acknowledgments
- Inspired by SoSoValue's SSI protocol
- Built on Stacks blockchain
- Utilizes Clarity smart contract language