pragma solidity ^0.4.13;

import "ds-token/token.sol";
import "ds-roles/roles.sol";

contract Cnx is DSToken("CNX") {
    uint8 public i;
    mapping (uint256 => prize) public prizes;

    event LogPurchase(address owner, uint256 prize);
    event LogPrize(uint256 pos, string title, string photo, uint128 cost, uint8 quantity);

    bool exchange = false;

    struct prize {
        string title;
        string photo;
        uint128 cost;
        uint8 quantity;
    }

    function Cnx() {
        setName("10th Anniversary Connaxis Token");
        mint(100000 * 10 ** 18);

        DSRoles roles = new DSRoles();
        setAuthority(roles);

        roles.setRoleCapability(1, this, bytes4(sha3("setUserRole(address,uint8,bool)")), true);
        roles.setRoleCapability(1, this, bytes4(sha3("startExchange()")), true);
        roles.setRoleCapability(1, this, bytes4(sha3("stopExchange()")), true);
        roles.setRoleCapability(1, this, bytes4(sha3("addPrize(string,string,uint128,uint8)")), true);
        roles.setRoleCapability(1, this, bytes4(sha3("editPrize(uint256,string,string,uint128,uint8)")), true);
        roles.setRoleCapability(1, this, bytes4(sha3("exchangePrize(uint256)")), true);
        roles.setRoleCapability(2, this, bytes4(sha3("exchangePrize(uint256)")), true);

        roles.setUserRole(msg.sender, 1, true);

        roles.setAuthority(roles);
        roles.setOwner(msg.sender);
    }

    function addPrize(string title, string photo, uint128 cost, uint8 quantity) auth {
        editPrize(++i, title, photo, cost, quantity);
    }

    function editPrize(uint256 pos, string title, string photo, uint128 cost, uint8 quantity) auth {
        prizes[pos].title = title;
        prizes[pos].photo = photo;
        prizes[pos].cost = cost;
        prizes[pos].quantity = quantity;
        LogPrize(pos, title, photo, cost, quantity);
    }

    function startExchange() auth {
        exchange = true;
    }

    function stopExchange() auth {
        exchange = false;
    }

    function exchangePrize(uint256 id) auth {
        assert(exchange);

        assert(prizes[id].quantity >= 1);
        assert(_balances[msg.sender] >= prizes[id].cost);

        burn(prizes[id].cost);
        prizes[i].quantity--;

        LogPurchase(msg.sender, id);
    }
}
