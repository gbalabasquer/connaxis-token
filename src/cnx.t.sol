pragma solidity ^0.4.8;

import "ds-test/test.sol";

import "./cnx.sol";
import "ds-roles/roles.sol";
import "ds-vault/vault.sol";

contract Test is DSTest {
    Cnx cnx;
    DSVault vault;
    FakePerson admin;
    FakePerson u1;
    FakePerson u2;
    FakePerson u3;

    function setUp() {
        cnx = new Cnx();
        vault = new DSVault();
        admin = new FakePerson(cnx, vault);

        DSRoles roles = new DSRoles();
        cnx.setAuthority(roles);
        vault.setAuthority(roles);

        roles.setRoleCapability(1, vault, bytes4(sha3("mint(uint128)")), true);
        roles.setRoleCapability(1, vault, bytes4(sha3("burn(uint128)")), true);
        roles.setRoleCapability(1, vault, bytes4(sha3("pull(address,uint128)")), true);
        roles.setRoleCapability(1, vault, bytes4(sha3("push(address,uint128)")), true);
        roles.setRoleCapability(1, cnx, bytes4(sha3("setUserRole(address,uint8,bool)")), true);
        roles.setRoleCapability(1, cnx, bytes4(sha3("addRequestExchange(string,string,uint128,address)")), true);
        roles.setRoleCapability(1, cnx, bytes4(sha3("editRequestExchange(uint256,string,string,uint128,address)")), true);
        roles.setRoleCapability(1, cnx, bytes4(sha3("acceptExchange(uint256)")), true);
        roles.setRoleCapability(2, cnx, bytes4(sha3("acceptExchange(uint256)")), true);
        roles.setRoleCapability(3, cnx, bytes4(sha3("mint(uint128)")), true);
        roles.setRoleCapability(3, cnx, bytes4(sha3("burn(uint128)")), true);

        roles.setUserRole(this, 1, true);
        roles.setUserRole(vault, 3, true);

        roles.setAuthority(roles);
        roles.setOwner(this);

        vault.swap(cnx);
        vault.mint(100000 * 10 ** 18);

        roles.setUserRole(admin, 1, true); 
        u1 = new FakePerson(cnx, vault);
        u2 = new FakePerson(cnx, vault);
        roles.setUserRole(u1, 2, true); 
        roles.setUserRole(u2, 2, true); 
        u3 = new FakePerson(cnx, vault);

        cnx.addRequestExchange('Iphone 7', 'http://blahblah', 1000 * 10 ** 18, u1);
        vault.push(this, 50000 * 10 ** 18);
        cnx.transfer(u1, 10000 * 10 ** 18);
        cnx.transfer(u2, 999 * 10 ** 18);
    }

    function testPushAdmin() {
        admin.push(u2, 500 * 10 ** 18);
    }

    function testFailPushUser() {
        u1.push(u2, 500 * 10 ** 18);
    }

    function testTransfer() {
        log_named_uint('balance', cnx.balanceOf(this));
        u1.transfer(u2, 500 * 10 ** 18);
    }

    function testAddRequestExchangeAdmin() {
        admin.addRequestExchange('Airpods', 'http://blahblah', 1000 * 10 ** 18, 0x0);
    }

    function testEditRequestExchangeAdmin() {
        admin.editRequestExchange(1, 'Iphone 6', 'http://blahblah', 1000 * 10 ** 18, 0x0);
    }

    function testFailAddRequestExchangeUser() {
        u1.addRequestExchange('BigBox', 'http://blahblah', 1000 * 10 ** 18, 0x0);
    }

    function testFailEditRequestExchangeUser() {
        u1.editRequestExchange(1, 'Iphone 6', 'http://blahblah', 1000 * 10 ** 18, 0x0);
    }

    function testAcceptExchange() {
        assertEq(cnx.balanceOf(u1), 10000 * 10 ** 18);
        var (,,,exchanged) = cnx.requests(1);
        assert(!exchanged);
        u1.acceptExchange(1);
        assertEq(cnx.balanceOf(u1), 9000 * 10 ** 18);
        var (,,,exchanged2) = cnx.requests(1);
        assert(exchanged2);
    }

    function testFailAcceptExchangeTwoTimes() {
        u1.acceptExchange(1);
        u1.acceptExchange(1);
    }

    function testFailAcceptExchangeOtherReceiver() {
        u1.acceptExchange(1);
        u2.acceptExchange(1);
    }

    function testFailAcceptExchangeNotEnoughBalance() {
        cnx.addRequestExchange('Iphone 7', 'http://blahblah', 1000 * 10 ** 18, u2);
        u2.acceptExchange(1);
    }

    function testFailAcceptExchangeNoAuthed() {
        cnx.transfer(u3, 10000 * 10 ** 18);
        cnx.addRequestExchange('Iphone 7', 'http://blahblah', 1000 * 10 ** 18, u3);
        u3.acceptExchange(1);
    }
}

contract FakePerson {
    Cnx cnx;
    DSVault vault;

    function FakePerson(Cnx _cnx, DSVault _vault) {
        cnx = _cnx;
        vault = _vault;
    }

    function transfer(address receipt, uint128 amount) {
        cnx.transfer(receipt, amount);
    }

    function push(address receipt, uint128 amount) {
        vault.push(receipt, amount);
    }

    function addRequestExchange(string title, string photo, uint128 cost, address receiver) {
        cnx.addRequestExchange(title, photo, cost, receiver);
    }

    function editRequestExchange(uint256 id, string title, string photo, uint128 cost, address receiver) {
        cnx.editRequestExchange(id, title, photo, cost, receiver);
    }

    function acceptExchange(uint256 id) {
        cnx.acceptExchange(id);
    }
}
