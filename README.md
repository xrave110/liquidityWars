## TODO
- [ ] Keeper to distribute RESOURCES (not transferable, ERC20 ?)
- [ ] Accept only cetrain Curve LP tokens (three tokens represents three nations (Orks, Elves, Dwarfs, Humans))
- [ ] Deposit LP tokens to gauge
- [ ] Keeper to finish game - distribution curve among participants depending on their RESOURCES. Curve will be distributed according following formula: User's RESOURCES / Total supply of RESOURCES. All deposited LPs will come back to the user.
- [ ] Building structure and objects functionalities (Farm, Barracks, Hideaway, Defense)
- [ ] Buildings should have bonuses depending on nation
- [ ] Troops should have different characteristics depending on nations
- [ ] Keeper to finish builds or just require function
- [ ] Battle system with thefts and random aspects
- [ ] Timer for attacks
- [ ] Every building upgrade and troops creation requires RESOURCES. RESOURCES used are partially burned from total supply (80%) and partially transferred to the smart contract (20%). At the end of the game Curve tokens associated with smart contract RESORCES will be distributed to the special protocol's multi sig vault. This will be the main source of earnings for the protocol.
- [ ] The protocol's vault will be periodically rebalanced via keepers to keep vault heathy (40% USDC, 10% ETH, 10% veCRV, 40% Curve pools (3Pool, TriCrypto))
- [ ] Functionality which disincentivise attacks on the same nation
- [ ] RESOURCES distribution will partially depend on APY of the pool which depend on voting results
- [ ] Utilities related to veCRV - players will vote for pools which reflects their nation


