# BeatShare 🎵

**Decentralized Music Royalty Distribution on Stacks**

BeatShare is a smart contract solution that enables transparent and automated royalty distribution for music collaborations on the Stacks blockchain. Artists can register their songs, define collaborator splits, and ensure fair compensation for all contributors.

## Features

- **Song Registration**: Artists can register their music with detailed metadata
- **Collaborative Splits**: Define percentage-based royalty splits between multiple collaborators
- **Transparent Distribution**: All royalty payments are recorded on-chain for full transparency
- **Automated Calculations**: Smart contract handles complex royalty calculations automatically

## Smart Contract Functions

### Public Functions

- `register-song(title, collaborators)` - Register a new song with royalty splits
- `distribute-royalties(song-id)` - Distribute accumulated royalties to collaborators

### Read-Only Functions

- `get-song(song-id)` - Retrieve song details and metadata
- `get-collaborator-split(song-id, collaborator)` - Get specific collaborator's percentage
- `get-artist-song-count(artist)` - Get total number of songs by an artist

## Usage Example

```clarity
;; Register a song with two collaborators
(contract-call? .beatshare register-song 
  "My Amazing Track"
  (list 
    { collaborator: 'SP1234..., percentage: u60 }
    { collaborator: 'SP5678..., percentage: u40 }
  )
)
```

## Technology Stack

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Development Tool**: Clarinet

## Getting Started

1. Clone this repository
2. Install Clarinet
3. Run `clarinet check` to verify contract syntax
4. Deploy to testnet for testing

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.