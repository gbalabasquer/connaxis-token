pragma solidity ^0.4.13;

import "ds-token/token.sol";

contract Cnx is DSToken("CNX") {
    uint8 public i;
    mapping (uint256 => request) public requests;

    event LogPurchase(address indexed receiver, uint256 pos);
    event LogRequest(address indexed receiver, uint256 pos, string title, string photo, uint128 cost);

    bool exchange = false;

    struct request {
        string title;
        string photo;
        uint128 cost;
        address receiver;
        bool exchanged;
    }

    function Cnx() {
        setName("10th Anniversary Connaxis Token");
    }

    function setPrizeVariables(uint256 pos, string title, string photo, uint128 cost, address receiver) internal {
        requests[pos].title = title;
        requests[pos].photo = photo;
        requests[pos].cost = cost;
        requests[pos].receiver = receiver;
        requests[pos].exchanged = false;
        LogRequest(receiver, pos, title, photo, cost);
    }

    function addRequestExchange(string title, string photo, uint128 cost, address receiver) auth {
        setPrizeVariables(++i, title, photo, cost, receiver);
    }

    function editRequestExchange(uint256 pos, string title, string photo, uint128 cost, address receiver) auth {
        assert(!requests[pos].exchanged);
        setPrizeVariables(pos, title, photo, cost, receiver);
    }

    function acceptExchange(uint256 pos) auth {
        assert(!requests[pos].exchanged);
        assert(msg.sender == requests[pos].receiver);

        assert(_balances[msg.sender] >= requests[pos].cost);

        burn(requests[pos].cost);
        requests[pos].exchanged = true;

        LogPurchase(msg.sender, pos);
    }
}
