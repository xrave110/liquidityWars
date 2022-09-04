//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.15;

import "../interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/** @title Game built with usage of curve pools as a core of reward system.
 *  @author Kamil Palenik
 *  @notice The purpose is to attract more liquidity to curve finance.
 *  @dev
 */
contract LiquidityWars is KeeperCompatibleInterface, Ownable {
    /* Types */
    enum GameState {
        OPEN, // open to entry
        PROCESSING, // game is processing
        INACTIVE // there is no game active or open entry
    }
    enum Nation {
        ORKS,
        ELVES,
        DWARFS,
        HUMANS
    }

    /* Structures */
    struct NationParams {
        address tokenAddress;
        uint entryAmount;
    }
    struct PlayerParams {
        Nation nation;
        uint resources;
        uint troops;
    }

    /* Variables */
    mapping(Nation => NationParams) public s_nationToLP;
    GameState private s_gameState = GameState.OPEN;
    uint256 private s_gameInterval = 1 minutes;
    uint256 private s_lastTimestamp;
    address[] private s_players;
    mapping(address => PlayerParams) private s_playerToParams;

    /* Events */
    event GameEnter(address indexed player);
    event ResourcesUpdated();

    constructor() {}

    /* Public Functions */
    function setGameInterval(uint _interval) public onlyOwner {
        s_gameInterval = _interval;
    }

    function setLPToNation(uint _nation, address _tokenAddress)
        public
        onlyOwner
    {
        s_nationToLP[Nation(_nation)].tokenAddress = _tokenAddress;
    }

    function setEntryAmount(uint _nation, uint _entryAmount) public onlyOwner {
        s_nationToLP[Nation(_nation)].entryAmount = _entryAmount;
    }

    function enterGame(uint _nation) public payable {
        require(
            s_nationToLP[Nation(_nation)].tokenAddress != address(0),
            "Wrong nation selected"
        );
        require(s_gameState == GameState.OPEN, "Game not open to enter");
        require(!checkIfPlayerEntered(msg.sender), "Player already entered");
        //temporary
        require(
            s_nationToLP[Nation(_nation)].entryAmount <= msg.value,
            "Not enough amount of tokens sent"
        );
        // IERC20(nationToLP[Nation(nation)])
        // if(msg.value < i_)
        s_players.push(msg.sender);
        s_playerToParams[msg.sender].nation = Nation(_nation);
    }

    function claimResources() public payable {
        require(
            getPlayerToResources(msg.sender) > 0,
            "You did not participated"
        );
        require(s_gameState == GameState.OPEN, "Game state is not OPEN");
        payable(msg.sender).transfer(
            s_nationToLP[s_playerToParams[msg.sender].nation].entryAmount
        );
    }

    function startGame() public onlyOwner {
        require(s_gameState == GameState.OPEN, "Game not open to start");
        s_gameState = GameState.PROCESSING;
        s_lastTimestamp = block.timestamp;
    }

    function endGame() public payable {
        uint256 idx;
        address[] memory players = s_players;
        require(
            s_gameState == GameState.PROCESSING,
            "Game not in processing state to finish it"
        );

        // for (idx = 0; idx < players.length; idx++) {
        //     payable(players[idx]).transfer(
        //         s_nationToLP[s_playerToParams[players[idx]].nation].entryAmount
        //     );
        // }
        s_gameState = GameState.OPEN; //Move up!
    }

    function checkIfPlayerEntered(address player) public view returns (bool) {
        uint256 idx;
        address[] memory players = s_players;
        for (idx = 0; idx < players.length; idx++) {
            if (players[idx] == player) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for the "upkeepNeeded" to return true.
     * The following should be true in order to return true:
     * 1. Our time interval should have passed
     * 2. The game should have at least 1 player and have some LP tokens
     * 3. Our subscription si funded with LINK
     * 4. The game should be in "open" state
     */
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        upkeepNeeded =
            (s_gameState == GameState.PROCESSING) &&
            ((block.timestamp - s_lastTimestamp) > s_gameInterval) &&
            (s_players.length > 0) &&
            (address(this).balance > 0);
        //return upkeepNeeded;
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        require(upkeepNeeded, "Upkeep not needed");
        address[] memory players = s_players;
        uint idx;
        for (idx = 0; idx < players.length; idx++) {
            s_playerToParams[players[idx]].resources++;
        }
        emit ResourcesUpdated();
    }

    function getGameState() public view returns (GameState) {
        return s_gameState;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLastTimestamp() public view returns (uint256) {
        return s_lastTimestamp;
    }

    function getPlayerToResources(address player)
        public
        view
        returns (uint256)
    {
        return s_playerToParams[player].resources;
    }

    function getAllPlayers() public view returns (address[] memory) {
        return s_players;
    }

    function getIfTimePassed() public view returns (bool) {
        return ((block.timestamp - s_lastTimestamp) > s_gameInterval);
    }

    function getBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
}
