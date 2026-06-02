---
name: web3-blockchain
description: Integrate Web3 and blockchain capabilities. Use when implementing wallet connections, smart contract interactions, or building decentralized applications.
---

# Web3 & Blockchain

## When to Use

- Connecting crypto wallets
- Interacting with smart contracts
- Building decentralized applications (dApps)
- Reading/writing blockchain data

## Input

- Blockchain requirements
- Smart contract ABIs
- Network configuration

## Output

- Wallet integration
- Smart contract interactions
- Transaction handling
- Event listening

## Checklist

1. **Wallet Setup**
   - Configure Web3 provider
   - Implement wallet connection
   - Handle network switching
   - Support multiple wallets

2. **Smart Contracts**
   - Define contract ABIs
   - Create contract instances
   - Implement read/write functions
   - Handle transaction states

3. **Transaction Handling**
   - Estimate gas
   - Handle pending states
   - Confirm transactions
   - Error handling

4. **Security**
   - Validate addresses
   - Check network
   - Handle reverts
   - Secure key management

## Best Practices

- Use established libraries (ethers.js, viem)
- Validate all addresses
- Handle network changes
- Implement proper error handling
- Use TypeScript for types
- Test on testnets first
- Monitor gas prices

## Anti-Patterns

❌ Storing private keys in code
❌ Not validating addresses
❌ Ignoring transaction errors
❌ Not handling network changes
❌ Hardcoded gas limits
❌ No loading states

## Validation

- Wallet connects successfully
- Transactions submit correctly
- Events are captured
- Error handling works
- Network switching functions

## Examples

### Example 1: Wallet Connection (ethers.js)
```typescript
// lib/web3/wallet.ts
import { ethers } from 'ethers';

export async function connectWallet(): Promise<{
  address: string;
  provider: ethers.BrowserProvider;
  signer: ethers.JsonRpcSigner;
}> {
  if (!window.ethereum) {
    throw new Error('No Web3 provider found');
  }

  const provider = new ethers.BrowserProvider(window.ethereum);
  
  // Request account access
  await provider.send('eth_requestAccounts', []);
  
  const signer = await provider.getSigner();
  const address = await signer.getAddress();
  
  return { address, provider, signer };
}

export async function getBalance(address: string): Promise<string> {
  const provider = new ethers.BrowserProvider(window.ethereum);
  const balance = await provider.getBalance(address);
  return ethers.formatEther(balance);
}

export function onAccountsChanged(callback: (accounts: string[]) => void) {
  window.ethereum?.on('accountsChanged', callback);
}

export function onChainChanged(callback: (chainId: string) => void) {
  window.ethereum?.on('chainChanged', callback);
}
```

### Example 2: Smart Contract Interaction
```typescript
// lib/web3/contract.ts
import { ethers } from 'ethers';

// Contract ABI (Application Binary Interface)
const ERC20_ABI = [
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function totalSupply() view returns (uint256)',
  'function balanceOf(address) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  'event Transfer(address indexed from, address indexed to, uint256 value)',
];

export class TokenContract {
  private contract: ethers.Contract;
  
  constructor(
    address: string,
    signerOrProvider: ethers.Signer | ethers.Provider
  ) {
    this.contract = new ethers.Contract(address, ERC20_ABI, signerOrProvider);
  }
  
  async getName(): Promise<string> {
    return await this.contract.name();
  }
  
  async getSymbol(): Promise<string> {
    return await this.contract.symbol();
  }
  
  async getBalance(address: string): Promise<bigint> {
    return await this.contract.balanceOf(address);
  }
  
  async transfer(to: string, amount: bigint): Promise<ethers.TransactionResponse> {
    const tx = await this.contract.transfer(to, amount);
    return tx;
  }
  
  async waitForTransaction(tx: ethers.TransactionResponse): Promise<ethers.TransactionReceipt> {
    const receipt = await tx.wait();
    if (!receipt) throw new Error('Transaction failed');
    return receipt;
  }
}
```

### Example 3: Transaction Handling
```typescript
// lib/web3/transaction.ts
import { ethers } from 'ethers';

export interface TransactionState {
  status: 'idle' | 'pending' | 'confirming' | 'success' | 'error';
  hash?: string;
  error?: string;
}

export async function sendTransaction(
  signer: ethers.JsonRpcSigner,
  to: string,
  value: bigint,
  data: string = '0x'
): Promise<TransactionState> {
  try {
    // Estimate gas
    const gasEstimate = await signer.estimateGas({
      to,
      value,
      data,
    });
    
    // Add 20% buffer
    const gasLimit = gasEstimate * 120n / 100n;
    
    // Send transaction
    const tx = await signer.sendTransaction({
      to,
      value,
      data,
      gasLimit,
    });
    
    return {
      status: 'pending',
      hash: tx.hash,
    };
  } catch (error: any) {
    return {
      status: 'error',
      error: error.message,
    };
  }
}

export async function waitForConfirmation(
  provider: ethers.Provider,
  txHash: string
): Promise<TransactionState> {
  try {
    const receipt = await provider.waitForTransaction(txHash);
    
    if (receipt?.status === 1) {
      return {
        status: 'success',
        hash: txHash,
      };
    } else {
      return {
        status: 'error',
        hash: txHash,
        error: 'Transaction reverted',
      };
    }
  } catch (error: any) {
    return {
      status: 'error',
      hash: txHash,
      error: error.message,
    };
  }
}
```

### Example 4: Event Listening
```typescript
// lib/web3/events.ts
import { ethers } from 'ethers';

export function listenToEvents(
  contract: ethers.Contract,
  eventName: string,
  callback: (...args: any[]) => void
) {
  contract.on(eventName, callback);
  
  return () => {
    contract.off(eventName, callback);
  };
}

// Usage
const contract = new ethers.Contract(address, ABI, provider);

const cleanup = listenToEvents(contract, 'Transfer', (from, to, value, event) => {
  console.log(`Transfer: ${from} -> ${to}: ${ethers.formatEther(value)}`);
});

// Stop listening
cleanup();
```

### Example 5: React Hook
```typescript
// hooks/useWeb3.ts
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

export function useWeb3() {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);
  const [address, setAddress] = useState<string | null>(null);
  const [chainId, setChainId] = useState<number | null>(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const connect = async () => {
    setIsConnecting(true);
    setError(null);
    
    try {
      if (!window.ethereum) {
        throw new Error('No Web3 provider found');
      }

      const provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send('eth_requestAccounts', []);
      
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      const network = await provider.getNetwork();
      
      setProvider(provider);
      setSigner(signer);
      setAddress(address);
      setChainId(Number(network.chainId));
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsConnecting(false);
    }
  };

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts: string[]) => {
        setAddress(accounts[0] || null);
      });

      window.ethereum.on('chainChanged', (chainId: string) => {
        setChainId(parseInt(chainId, 16));
      });
    }
  }, []);

  return {
    provider,
    signer,
    address,
    chainId,
    isConnecting,
    error,
    connect,
  };
}
```

## Supported Networks

| Network | Chain ID | Currency |
|---------|----------|----------|
| Ethereum Mainnet | 1 | ETH |
| Polygon | 137 | MATIC |
| Arbitrum | 42161 | ETH |
| Optimism | 10 | ETH |
| Base | 8453 | ETH |
| Sepolia (Testnet) | 11155111 | ETH |

## Output Structure

```
├── lib/
│   ├── web3/
│   │   ├── wallet.ts        # Wallet connection
│   │   ├── contract.ts      # Contract interactions
│   │   ├── transaction.ts   # Transaction handling
│   │   └── events.ts        # Event listening
│   └── contracts/
│       ├── abi/             # Contract ABIs
│       └── addresses.ts     # Contract addresses
├── hooks/
│   └── useWeb3.ts           # React hook
├── components/
│   ├── ConnectWallet.tsx    # Wallet button
│   └── TransactionStatus.tsx
└── config/
    └── networks.ts          # Network configuration
```
