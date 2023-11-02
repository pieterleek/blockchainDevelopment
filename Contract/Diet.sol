// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./YourOwnNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Diet {
    using SafeMath for uint256;

    // Constants
    uint256 public constant CALORIESPERSKILO = 7700;

    // State variables
    address private manager;
    AndrehNFT private andrehNFT;
    uint256 private minimumStartAmount;
    mapping(address => Participant) private participants;
    mapping(address => uint256[]) private progress;

    // Events
    event Participate(address indexed participant, uint256 weight, uint256 target);
    event WeightUpdated(address indexed participant, uint256 weight);
    event Rewarded(address indexed participant);

    constructor(uint256 _minimumStartAmount) {
        manager = msg.sender;
        minimumStartAmount = _minimumStartAmount.mul(1 ether);
        andrehNFT = new AndrehNFT();
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    modifier ensureParticipation() {
        require(participants[msg.sender].owner != address(0), "Not a participant");
        _;
    }

    modifier checkMinEth() {
        require(msg.value >= minimumStartAmount, "Insufficient ETH sent");
        _;
    }

    function participate(uint256 _weight, uint256 _target) external payable checkMinEth {
        require(participants[msg.sender].owner == address(0), "Already participating");
        participants[msg.sender] = Participant(payable(msg.sender), msg.value, _target);
        progress[msg.sender].push(_weight);
        emit Participate(msg.sender, _weight, _target);
    }

    function updateWeight(uint256 _weight) external ensureParticipation {
        progress[msg.sender].push(_weight);
        emit WeightUpdated(msg.sender, _weight);
    }

    function rewardMe() external ensureParticipation {
        require(isTargetAchieved(msg.sender), "Target not achieved");
        
        address payable participantAddress = payable(msg.sender);
        uint256 rewardAmount = participants[msg.sender].payment;

        participantAddress.transfer(rewardAmount);

        if(andrehNFT.unmintedLen() > 0) {
            andrehNFT.makeNFT(msg.sender);
        }

        delete participants[msg.sender];
        emit Rewarded(msg.sender);
    }

    function isTargetAchieved(address user) public view returns (bool) {
        uint256 lastWeight = progress[user][progress[user].length - 1];
        return participants[user].target == lastWeight;
    }

    function getNFTDetails() external view returns(uint256 totalSupply, string memory name, string memory symbol) {
        return (andrehNFT.totalSupply(), andrehNFT.name(), andrehNFT.symbol());
    }

    function getOwnedURIs() public view returns(string[] memory) {
        return andrehNFT.getOwnedURIs(msg.sender);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyManager {
        IERC20(tokenAddress).transfer(manager, tokenAmount);
    }

    function isManager() external view returns(bool) {
        return msg.sender == manager;
    }
}
