from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, add_uint256

# Contract storage variables
@storage_var
func balance() -> (res: Uint256):
end

@storage_var
func last_transfer_time() -> (res: felt):
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
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    let (current_time) = syscall_get_block_timestamp()
    last_transfer_time.write(current_time)
    balance.write(Uint256(0, 0))
    return ()
end

# Deposit funds into the contract
@external
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256):
    let (current_balance) = balance.read()
    let (new_balance) = add_uint256(current_balance, amount)
    balance.write(new_balance)
    return ()
end

# Withdraw funds from the contract
@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt,
    amount: Uint256
):
    # Check that one month has passed since the last transfer
    let (current_time) = syscall_get_block_timestamp()
    let (last_time) = last_transfer_time.read()
    assert current_time - last_time >= 2592000  # 30 days in seconds

    # Check contract balance
    let (current_balance) = balance.read()
    let (new_balance) = sub_uint256(current_balance, amount)

    balance.write(new_balance)
    last_transfer_time.write(current_time)
    Transfer.emit(to, amount)
    return ()
end