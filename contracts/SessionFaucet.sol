// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * SessionFaucet
 *
 * Peter deploys this on Sepolia and funds it with test ETH.
 * Students write a contract that calls requestFunds() on this address.
 * Peter watches for FundRequest events on Etherscan and calls approve()
 * for each student whose contract called in correctly.
 * First student to get approved wins.
 *
 * Session: Web3 Identity — Session 3
 * Network: Sepolia Testnet
 * Facilitator: Peter Manda
 */
contract SessionFaucet {

    address public owner;

    // The most any one request can ask for, set at deploy time
    uint256 public maxRequestAmount;

    // Tracks how much each contract address has requested
    mapping(address => uint256) public pendingRequests;

    // Peter can pause requests mid-session if needed
    bool public paused;

    event FundRequest(
        address indexed requester,
        uint256 amount,
        uint256 timestamp
    );
    event FundsApproved(address indexed recipient, uint256 amount);
    event FundsDenied(address indexed requester, string reason);
    event Paused(bool isPaused);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the facilitator can call this");
        _;
    }

    modifier notPaused() {
        require(!paused, "Requests are paused. Check with Peter.");
        _;
    }

    /**
     * Deploy with a max request limit in wei.
     * Fund the contract at deploy time or send ETH to it later.
     *
     * Example: 0.05 ETH limit = 50000000000000000 wei
     * Use https://eth-converter.com to convert
     */
    constructor(uint256 _maxRequestInWei) payable {
        owner = msg.sender;
        maxRequestAmount = _maxRequestInWei;
        paused = false;
    }

    /**
     * Students call this from inside their smart contract.
     * The address that calls this is msg.sender — which will be the
     * student's contract address, not their wallet address.
     *
     * amount is in wei. Ask Peter what the session cap is.
     * 0.01 ETH = 10000000000000000 wei
     */
    function requestFunds(uint256 amount) external notPaused {
        require(amount > 0, "Amount must be greater than zero");
        require(
            amount <= maxRequestAmount,
            "Request exceeds the session limit. Ask Peter what the cap is."
        );
        require(
            address(this).balance >= amount,
            "Faucet does not have enough ETH for this request"
        );

        // Overwrite any previous request from this address
        // A student can re-request if they get the amount wrong
        pendingRequests[msg.sender] = amount;

        emit FundRequest(msg.sender, amount, block.timestamp);
    }

    /**
     * Peter calls this to send ETH to the student's contract.
     * recipient is the address of the student's deployed contract,
     * not their personal wallet address.
     *
     * Peter finds the recipient address from the FundRequest event
     * on Etherscan under the contract's Events tab.
     */
    function approve(address payable recipient) external onlyOwner {
        uint256 amount = pendingRequests[recipient];
        require(amount > 0, "No pending request from this address");
        require(
            address(this).balance >= amount,
            "Faucet balance too low to approve"
        );

        // Clear the request before sending to prevent re-entry
        pendingRequests[recipient] = 0;

        (bool sent, ) = recipient.call{value: amount}("");
        require(sent, "Transfer to student contract failed");

        emit FundsApproved(recipient, amount);
    }

    /**
     * Peter can reject a request and clear it from the queue.
     * Useful if a student makes a bad request mid-session.
     */
    function deny(
        address requester,
        string calldata reason
    ) external onlyOwner {
        pendingRequests[requester] = 0;
        emit FundsDenied(requester, reason);
    }

    /**
     * Pause or unpause requests.
     * Use this at the start or end of the exercise window.
     */
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit Paused(_paused);
    }

    /**
     * Update the per-request limit mid-session if needed.
     */
    function setMaxRequest(uint256 newMaxInWei) external onlyOwner {
        maxRequestAmount = newMaxInWei;
    }

    /**
     * Check how much ETH the faucet still holds.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * Peter withdraws remaining ETH at the end of the session.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to withdraw");

        (bool sent, ) = payable(owner).call{value: balance}("");
        require(sent, "Withdrawal failed");
    }

    // Accepts direct ETH deposits to top up the faucet between approvals
    receive() external payable {}
}
