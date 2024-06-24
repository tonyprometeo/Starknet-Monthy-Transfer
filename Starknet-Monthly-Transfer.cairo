%lang starknet

from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub

# Contract storage variables
@storage_var
func balance() -> Uint256:
end

@storage_var
func last_transfer_time() -> felt:
end

# Event for transfer
@event
func Transfer(
    to: felt,
    amount: Uint256,
):
end

# Initialize the contract
@constructor
func constructor():
    let (current_time) = get_block_timestamp()
    last_transfer_time.write(current_time)
    balance.write(Uint256(0, 0))
    return ()
end

# Deposit funds into the contract
@external
func deposit(amount: Uint256):
    let (current_balance) = balance.read()
    let (new_balance) = uint256_add(current_balance, amount)
    balance.write(new_balance)
    return ()
end

# Withdraw funds from the contract
@external
func withdraw(to: felt, amount: Uint256):
    # Check that one month has passed since the last transfer
    let (current_time) = get_block_timestamp()
    let (last_time) = last_transfer_time.read()
    assert current_time - last_time >= 2592000, "One month has not passed since the last transfer"

    # Check contract balance
    let (current_balance) = balance.read()
    let (is_enough_funds, new_balance) = uint256_sub(current_balance, amount)
    assert is_enough_funds, "Not enough funds"

    balance.write(new_balance)
    last_transfer_time.write(current_time)
    Transfer.emit(to, amount)
    return ()
end
