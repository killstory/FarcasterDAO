import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import FarcasterDAOABI from './FarcasterDAOABI.json';

function App() {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState('');
  const [description, setDescription] = useState('');
  const [ipfsHash, setIpfsHash] = useState('');

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        try {
          await window.ethereum.enable();
          setWeb3(web3Instance);
          const accounts = await web3Instance.eth.getAccounts();
          setAccount(accounts[0]);

          const contractAddress = '0x...'; // Your deployed contract address
          const contractInstance = new web3Instance.eth.Contract(FarcasterDAOABI, contractAddress);
          setContract(contractInstance);
        } catch (error) {
          console.error("User denied account access");
        }
      }
    };
    initWeb3();
  }, []);

  const createProposal = async (e) => {
    e.preventDefault();
    if (contract && account) {
      try {
        await contract.methods.createProposal(description, ipfsHash).send({ from: account });
        console.log("Proposal created successfully");
        setDescription('');
        setIpfsHash('');
      } catch (error) {
        console.error("Error creating proposal:", error);
      }
    }
  };

  return (
    <div className="App">
      <h1>Farcaster DAO</h1>
      <p>Connected Account: {account}</p>
      <form onSubmit={createProposal}>
        <input
          type="text"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Proposal Description"
        />
        <input
          type="text"
          value={ipfsHash}
          onChange={(e) => setIpfsHash(e.target.value)}
          placeholder="IPFS Hash"
        />
        <button type="submit">Create Proposal</button>
      </form>
    </div>
  );
}

export default App;
