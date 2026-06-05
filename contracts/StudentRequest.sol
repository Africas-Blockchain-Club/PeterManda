// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * StudentRequest — Session 3 Contract Race
 *
 * Your mission: deploy this contract on Sepolia and successfully call
 * requestFunds() on Peter's SessionFaucet contract.
 *
 * When Peter sees your FundRequest event on Etherscan, he will call approve().
 * First student to get approved wins.
 *
 * Rules:
 * - You are allowed to use AI to help you write and debug this
 * - You may NOT touch Peter's faucet contract directly
 * - You must go through your own deployed contract to make the request
 * - The contract that calls requestFunds correctly wins — not the cleanest one
 *
 * Steps:
 * 1. Replace PETER_FAUCET_ADDRESS with the address Peter gives you
 * 2. Compile and deploy this contract on Sepolia using Remix
 * 3. Call makeRequest() with an amount in wei
 * 4. Watch the SessionFaucet Events tab on Etherscan for your FundRequest event
 * 5. Wait for Peter to call approve() — then call withdraw() to collect
 *
 * Convert ETH to wei here: https://eth-converter.com
 * Ask Peter what the per-request cap is before you call makeRequest()
 */

// TODO 1 — UNDERSTAND THIS INTERFACE
// This tells your contract how to talk to Peter's faucet.
// An interface defines what functions exist on another contract
// without needing its full code. Do not change it.
interface ISessionFaucet {
    function requestFunds(uint256 amount) external;
}

contract StudentRequest {

    address public owner;
    address public faucetAddress;

    event RequestSent(address indexed faucet, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    // TODO 2 — SET THE FAUCET ADDRESS AT DEPLOY TIME
    // Peter will give you the deployed SessionFaucet address in the session.
    // Replace the placeholder below before you compile.
    // Example: constructor(address _faucet) where _faucet = "0xABC...123"
    constructor(address _faucet) {
        require(_faucet != address(0), "Faucet address cannot be zero");
        owner = msg.sender;
        faucetAddress = _faucet;
    }

    modifier onlyOwner() {
        // TODO 3 — WHY IS THIS CHECK HERE?
        // What happens if anyone can call makeRequest()?
        // Think about who owns this contract and who should control it.
        require(msg.sender == owner, "Not your contract");
        _;
    }

    /**
     * Call this to send your fund request to Peter's faucet.
     *
     * amount is in wei.
     * Session cap: 0.008 ETH = 8000000000000000 wei. Asking for more reverts.
     * Asking for more than the cap will revert the transaction.
     */
    function makeRequest(uint256 amount) external onlyOwner {
        // TODO 4 — TRACE THIS CALL
        // Which contract does this line talk to?
        // Which function is it calling on that contract?
        // What does msg.sender look like from the faucet's perspective?
        ISessionFaucet(faucetAddress).requestFunds(amount);

        emit RequestSent(faucetAddress, amount);
    }

    /**
     * This function lets your contract receive ETH.
     * When Peter calls approve() on the faucet, the faucet sends ETH here.
     *
     * TODO 5 — WHY IS receive() NEEDED?
     * Remove it mentally and think: what happens when someone tries
     * to send ETH to a contract that has no receive() function?
     */
    receive() external payable {}

    /**
     * After Peter sends ETH to this contract, call this to move it
     * to your personal MetaMask wallet.
     *
     * You are withdrawing from your own contract — not from Peter's.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        // TODO 6 — READ THIS ERROR MESSAGE
        // Why does the message say "Wait for Peter"?
        // What has to happen before there is anything to withdraw?
        require(
            balance > 0,
            "Nothing here yet. Wait for Peter to approve your request."
        );

        (bool sent, ) = payable(owner).call{value: balance}("");
        require(sent, "Withdrawal to your wallet failed");

        emit Withdrawn(owner, balance);
    }

    /**
     * Check how much ETH is sitting in this contract right now.
     * Use this to confirm Peter's approval came through.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
