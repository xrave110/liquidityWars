# 1. Get your SubId for Chainlink VRF
# 2. Deploy our contract using the SubId
# 3. Register the contract with Chainlink & it's subId
# 4. Register the contract with chainlink Keepers
# 5. Run staging tests
import pytest
from fixtures import *
from brownie import chain
import time


def test_resource_increase(liquidity_wars, owner, user1, user2, init_game):
    MIN_TO_WAIT = 3
    SEC_TO_WAIT = MIN_TO_WAIT * 60
    final_time = time.time() + SEC_TO_WAIT
    init_state_of_owner = liquidity_wars.getPlayerToResources(owner.address)
    init_state_of_user1 = liquidity_wars.getPlayerToResources(user1.address)
    init_state_of_user2 = liquidity_wars.getPlayerToResources(user2.address)
    print("Sleep...")
    time.sleep(SEC_TO_WAIT)
    final_state_of_owner = liquidity_wars.getPlayerToResources(owner.address)
    print(
        "Initial state: {}\nFinal state: {}".format(
            init_state_of_owner, final_state_of_owner
        )
    )
    final_state_of_user1 = liquidity_wars.getPlayerToResources(user1.address)
    final_state_of_user2 = liquidity_wars.getPlayerToResources(user2.address)
    assert final_state_of_owner == init_state_of_owner + MIN_TO_WAIT
