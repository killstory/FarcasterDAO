// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FarcasterDAO is ERC20, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _proposalIds;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        string ipfsHash;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description, string ipfsHash);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(uint256 initialSupply) ERC20("FarcasterDAO Token", "FCAST") {
        _mint(msg.sender, initialSupply);
    }

    function createProposal(string memory description, string memory ipfsHash) public {
        require(balanceOf(msg.sender) > 0, "Must hold tokens to create a proposal");
        
        _proposalIds.increment();
        uint256 newProposalId = _proposalIds.current();
        
        Proposal storage newProposal = proposals[newProposalId];
        newProposal.id = newProposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = description;
        newProposal.ipfsHash = ipfsHash;

        emit ProposalCreated(newProposalId, msg.sender, description, ipfsHash);
    }

    function vote(uint256 proposalId, bool support) public {
        require(balanceOf(msg.sender) > 0, "Must hold tokens to vote");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.hasVoted[msg.sender], "Already voted on this proposal");

        uint256 votes = balanceOf(msg.sender);

        if (support) {
            proposal.forVotes += votes;
        } else {
            proposal.againstVotes += votes;
        }

        proposal.hasVoted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, support, votes);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.forVotes > proposal.againstVotes, "Proposal did not pass");

        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }
}
