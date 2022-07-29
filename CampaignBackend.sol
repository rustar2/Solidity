//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract factoryCampaign{ //function that creates more than 1 campaign as an admin
    address[] public createdCampaigns;
    function createNewCampaign(uint minimum) public {
       address(new CampaignContract(minimum, msg.sender));
       createdCampaigns.push(address(new CampaignContract(minimum, msg.sender)));
    }
    function listOfCreatedCampaigns() public view returns(address[] memory){
        return createdCampaigns;
    }
}
contract CampaignContract {
    constructor(uint minimum, address creator){
        minimumContribute = minimum;
        manager=creator;
    }
    struct approvedsList{
        address approversAdress;
        uint whichRequestAsIndex;
    }
    approvedsList[] public approvedslist;
    mapping (address => bool) public isApprovers;
    mapping(bool => address) public findApprovers;
    address public manager;
    uint public minimumContribute;
    struct Request{
        string description; //description
        uint value; //amount of money
        address payable recipient; //the one whom sent to
        bool complete;//is Request done?
        uint approvedCounts;//the number of Requests that done
        mapping(address => bool) approveds;
    }
    Request[] requests;
    modifier restricted(){
        require(msg.sender == manager);_;
    }
    
    uint contributedCounts = 0;
    function Contribute() public payable{
        require(msg.value > minimumContribute);
        isApprovers[msg.sender]=true;
        findApprovers[true]=msg.sender;//not really necessary for now
        contributedCounts++;
    }
    uint numRequests;
    mapping (uint => Request) public requestts;
    function createRequest(string memory description, uint value, address payable recipient) public payable 
    restricted{
        //require(isApprovers[msg.sender]);//For creating a request u must contribute first."Edited: No need"
        Request storage newRequest = requestts[numRequests++];
        newRequest.description = description;
        newRequest.value = value;
        require(value > minimumContribute);// value that will be withdraw must be bigger than contributed
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvedCounts = 0;
        
    }
    mapping(address => bool) public isContributerApproved;//is any contributer approved anything
    function approveRequest(uint index) public{// choose the request u want to approve
        require(isApprovers[msg.sender]);
        Request storage request = requestts[index];
        require(!request.approveds[msg.sender]);
        request.approveds[msg.sender] = true;
        request.approvedCounts++;
        approvedslist.push(approvedsList(msg.sender, index));//what contributer approved
        isContributerApproved[msg.sender] = true;

    }
    function finalizeRequest(uint index) public restricted{
        Request storage request = requestts[index];
        require(!request.complete);
        require(request.approvedCounts > (contributedCounts/2));
        request.complete = true;
        request.recipient.transfer(request.value);
    }}
