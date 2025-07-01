// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title RaffleWheel
/// @notice A simple raffle contract that stores player nicknames and picks a winner
contract RaffleWheel {
    /// @notice Maps each participant's address to their nickname
    mapping(address => string) public names;

    /// @notice List of all players who entered the raffle
    address[] public players;

    /// @notice Address of the last winner
    address public lastWinner;

    /// @notice Allows a user to enter the raffle with a nickname
    /// @param name The nickname provided by the user
    /// Requires an entry fee of exactly 0.001 ETH
    function enter(string memory name) public payable {
        require(msg.value == 0.001 ether, "Entry fee is 0.001 ETH");
        require(bytes(name).length > 0, "Name cannot be empty");

        // Add the player's address to the list
        players.push(msg.sender);

        // Store the player's nickname
        names[msg.sender] = name;
    }

    /// @notice Selects a random winner, sends them the contract balance, emits an event
    function pickWinner() public {
        require(players.length > 0, "No players");

        // Generate a pseudo-random number using block properties and players count
        uint random = uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp,    // current timestamp
                    block.prevrandao,   // randomness provided by the network
                    players.length      // number of players
                )
            )
        );

        // Calculate index of the winner
        uint winnerIndex = random % players.length;

        // Retrieve the winner's address
        address winnerAddr = players[winnerIndex];

        // Retrieve the winner's nickname
        string memory winnerName = names[winnerAddr];

        // Store the winner address
        lastWinner = winnerAddr;

        // Transfer all funds in the contract to the winner
        payable(winnerAddr).transfer(address(this).balance);

        // Emit an event announcing the winner
        emit WinnerSelected(winnerAddr, winnerName);

        // Clear the players list for the next round
        delete players;
    }

    /// @notice Emitted when a winner is selected
    /// @param winner The address of the winner
    /// @param name The nickname of the winner
    event WinnerSelected(address winner, string name);
}
