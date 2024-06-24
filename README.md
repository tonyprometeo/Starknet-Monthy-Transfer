# Starknet Monthly Transfer

## ⚠️ WARNING: NOT TESTED ⚠️

This project implements a Starknet smart contract that facilitates monthly Ethereum transfers automatically. It ensures scheduled payments are made securely and efficiently.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contract Details](#contract-details)
- [License](#license)

## Introduction

The Starknet Monthly Transfer contract is designed to automate the process of transferring a specified amount of Ethereum on a monthly basis. This is particularly useful for subscription services, regular donations, or any situation where periodic payments are required.

## Features

- **Automated Monthly Transfers**: Ensures a specified amount is transferred every month.
- **Deposit and Withdrawal**: Allows users to deposit funds into the contract and withdraw them according to the schedule.
- **Event Logging**: Emits events for deposits and transfers, providing transparency and traceability.

## Installation

To get started with the Starknet Monthly Transfer contract, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/tonyprometeo/Starknet-Monthly-Transfer.git
   cd Starknet-Monthly-Transfer
   ```

2. **Install Cairo**:
   Follow the official [Cairo installation guide](https://www.cairo-lang.org/tutorials/getting-started-with-cairo/).

3. **Compile the contract**:
   ```bash
   cairo-compile contract.cairo --output contract_compiled.json
   ```

4. **Deploy the contract**:
   Use the `starknet` CLI or a compatible wallet to deploy the contract to the Starknet network:
   ```bash
   starknet deploy --contract contract_compiled.json --network alpha
   ```

## Usage

### Depositing Funds

To deposit funds into the contract, call the `deposit` function with the amount to deposit:

```python
@external
func deposit(amount: Uint256):
    let (current_balance) = balance.read()
    let (new_balance) = uint256_add(current_balance, amount)
    balance.write(new_balance)
    return ()
end
```

### Withdrawing Funds

To withdraw funds, call the `withdraw` function with the recipient address and the amount to transfer. Note that this function can only be called once per month:

```python
@external
func withdraw(to: felt, amount: Uint256):
    let (current_time) = get_block_timestamp()
    let (last_time) = last_transfer_time.read()
    assert current_time - last_time >= 2592000, "One month has not passed since the last transfer"

    let (current_balance) = balance.read()
    let (is_enough_funds, new_balance) = uint256_sub(current_balance, amount)
    assert is_enough_funds, "Not enough funds"

    balance.write(new_balance)
    last_transfer_time.write(current_time)
    Transfer.emit(to, amount)
    return ()
end
```

## Contract Details

### Storage Variables

- **balance**: Stores the current balance of the contract.
- **last_transfer_time**: Stores the timestamp of the last transfer.

### Events

- **Transfer**: Emitted when a transfer is made.

### Functions

- **constructor**: Initializes the contract with the current timestamp.
- **deposit**: Allows depositing funds into the contract.
- **withdraw**: Allows withdrawing funds from the contract, ensuring that one month has passed since the last transfer.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

