// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSystem {
    // Struct to store voter information
    struct Voter {
        bool hasVoted;
        uint256 vote; // Index of the candidate voted for
    }

    // Struct to store candidate information
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // Contract owner
    address public owner;
    
    // Mapping of voter addresses to their voting status
    mapping(address => Voter) public voters;
    
    // Array of candidates
    Candidate[] public candidates;
    
    // Voting period
    uint256 public votingEndTime;
    bool public votingClosed;

    // Events for transparency
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint256 candidateIndex);
    event VotingEnded(uint256 timestamp);
    event CandidateAdded(string name);

    // Constructor - Initialize with Trump and Kamala
    constructor(uint256 _votingDurationInMinutes) {
        owner = msg.sender;
        
        // Add candidates (Trump and Kamala)
        candidates.push(Candidate("Trump", 0));
        candidates.push(Candidate("Kamala", 0));
        
        // Emit events for candidate addition
        emit CandidateAdded("Trump");
        emit CandidateAdded("Kamala");
        
        // Set voting end time
        votingEndTime = block.timestamp + (_votingDurationInMinutes * 1 minutes);
        votingClosed = false;
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier votingOpen() {
        require(block.timestamp <= votingEndTime, "Voting has ended");
        require(!votingClosed, "Voting is closed");
        _;
    }

    // Function to vote
    function vote(uint256 _candidateIndex) external votingOpen {
        Voter storage voter = voters[msg.sender];
        
        // Check if voter hasn't voted yet
        require(!voter.hasVoted, "You have already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");
        
        // Record the vote
        voter.hasVoted = true;
        voter.vote = _candidateIndex;
        candidates[_candidateIndex].voteCount++;
        
        // Emit vote event for transparency
        emit VoteCast(msg.sender, _candidateIndex);
    }

    // Function to get candidate details
    function getCandidate(uint256 _index) external view returns (string memory name, uint256 voteCount) {
        require(_index < candidates.length, "Invalid candidate index");
        Candidate memory candidate = candidates[_index];
        return (candidate.name, candidate.voteCount);
    }

    // Function to get total number of candidates
    function getCandidatesCount() external view returns (uint256) {
        return candidates.length;
    }

    // Function to check if address has voted
    function hasVoted(address _voter) external view returns (bool) {
        return voters[_voter].hasVoted;
    }

    // Function to end voting manually (only owner)
    function endVoting() external onlyOwner {
        require(!votingClosed, "Voting already closed");
        votingClosed = true;
        emit VotingEnded(block.timestamp);
    }

    // Function to get voting status
    function getVotingStatus() external view returns (bool) {
        return block.timestamp <= votingEndTime && !votingClosed;
    }
}