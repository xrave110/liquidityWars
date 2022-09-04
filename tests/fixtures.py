from brownie import (
    network,
    config,
    interface,
    accounts,
    LiquidityWars,
    ETH_ADDRESS,
    web3,
)
import pytest


LOCAL_NETWORK = ["development", "mainnet-fork"]

ENTRY_FEE = web3.toWei(0.02, "Ether")


@pytest.fixture(scope="module")
def owner():
    if network.show_active() not in LOCAL_NETWORK:
        accounts.add(config["wallets"]["from_key"])
    yield accounts[0]


@pytest.fixture(scope="module")
def user1():
    if network.show_active() not in LOCAL_NETWORK:
        accounts.add(config["wallets"]["from_key1"])
    yield accounts[1]


@pytest.fixture(scope="module")
def user2():
    if network.show_active() not in LOCAL_NETWORK:
        accounts.add(config["wallets"]["from_key2"])
    yield accounts[2]


@pytest.fixture(scope="module")
def liquidity_wars(owner):
    if network.show_active() in LOCAL_NETWORK:
        # Local
        contract = LiquidityWars.deploy({"from": owner})
    else:
        # Testnets/ Mainnets
        try:
            contract = LiquidityWars[-1]
        except IndexError:
            contract = LiquidityWars.deploy({"from": owner})
    print("Contract address {}".format(contract.address))
    yield contract


@pytest.fixture(scope="module")
def nations_setup(liquidity_wars, owner):
    print("Nation settings...")
    liquidity_wars.setLPToNation(0, ETH_ADDRESS, {"from": owner})


@pytest.fixture(scope="module")
def enter_game(owner, user1, user2, liquidity_wars):
    if liquidity_wars.getGameState() != 0:
        liquidity_wars.endGame({"from": owner})
    print("Users entering to the game...")
    liquidity_wars.enterGame(0, {"from": owner, "value": ENTRY_FEE})
    liquidity_wars.enterGame(0, {"from": user1, "value": ENTRY_FEE})
    liquidity_wars.enterGame(0, {"from": user2, "value": ENTRY_FEE})


@pytest.fixture(scope="module")
def init_game(nations_setup, enter_game, owner, liquidity_wars):
    print("Initializing game ...")
    dictOfInitStates = {}
    liquidity_wars.startGame({"from": owner})
    dictOfInitStates["GameState"] = liquidity_wars.getGameState()
    dictOfInitStates["NumberOfPlayers"] = liquidity_wars.getNumberOfPlayers()
    dictOfInitStates["LastTimestamp"] = liquidity_wars.getLastTimestamp()
    print(
        "Contract address: {}\nContract Balance: {}\nGame state: {}\nNumber of players: {}\n".format(
            liquidity_wars.address,
            web3.fromWei(liquidity_wars.balance(), "ether"),
            dictOfInitStates["GameState"],
            dictOfInitStates["NumberOfPlayers"],
        )
    )
    yield dictOfInitStates
    liquidity_wars.endGame({"from": owner})


@pytest.fixture(scope="module")
def teardown(liquidity_wars, owner):
    liquidity_wars.endGame({"from": owner})