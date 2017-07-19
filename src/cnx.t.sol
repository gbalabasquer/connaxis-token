pragma solidity ^0.4.8;

import "ds-test/test.sol";

import "./cnx.sol";

contract Test is DSTest {
    Cnx cnx;
    FakePerson admin;
    FakePerson u1;
    FakePerson u2;
    FakePerson u3;

    function setUp() {
        cnx = new Cnx();
        admin = new FakePerson(cnx);

        var roles = DSRoles(address(cnx.authority()));

        roles.setUserRole(admin, 1, true); 
        u1 = new FakePerson(cnx);
        u2 = new FakePerson(cnx);
        roles.setUserRole(u1, 2, true); 
        roles.setUserRole(u2, 2, true); 
        u3 = new FakePerson(cnx);

        cnx.addPrize('Iphone 7', 'http://blahblah', 1000 * 10 ** 18, 2);

        cnx.transfer(u1, 10000 * 10 ** 18);
        cnx.transfer(u2, 10000 * 10 ** 18);
    }

    function testTransfer() {
        u1.transfer(u2, 500 * 10 ** 18);
    }

    function testAddPrize() {
        admin.addPrize('Airpods', 'http://blahblah', 1000 * 10 ** 18, 2);
    }

    function testEditPrize() {
        admin.editPrize(1, 'Iphone 6', 'http://blahblah', 1000 * 10 ** 18, 2);
    }

    function testFailAddPrize() {
        u1.addPrize('BigBox', 'http://blahblah', 1000 * 10 ** 18, 2);
    }

    function testFailEditPrize() {
        u1.editPrize(1, 'Iphone 6', 'http://blahblah', 1000 * 10 ** 18, 2);
    }

    function testExchangePrize() {
        cnx.startExchange();
        assertEq(cnx.balanceOf(this), 80000 * 10 ** 18);
        var (,,,quantity) = cnx.prizes(1);
        assertEq(uint(quantity), 2);
        cnx.exchangePrize(1);
        assertEq(cnx.balanceOf(this), 79000 * 10 ** 18);
        var (,,,quantity2) = cnx.prizes(1);
        assertEq(uint(quantity2), 1);

        assertEq(cnx.balanceOf(u1), 10000 * 10 ** 18);
        u1.exchangePrize(1);
        assertEq(cnx.balanceOf(u1), 9000 * 10 ** 18);
        var (,,,quantity3) = cnx.prizes(1);
        assertEq(uint(quantity3), 0);
    }

    function testFailExchangePrizeNoStarted() {
        cnx.exchangePrize(1);
    }

    function testFailExchangePrizeNoAuthed() {
        cnx.startExchange();
        u3.exchangePrize(1);
    }
}

contract FakePerson {
    Cnx cnx;

    function FakePerson(Cnx _cnx) {
        cnx = _cnx;
    }

    function transfer(address receipt, uint128 amount) {
        cnx.transfer(receipt, amount);
    }

    function addPrize(string title, string photo, uint128 cost, uint8 quantity) {
        cnx.addPrize(title, photo, cost, quantity);
    }

    function editPrize(uint256 id, string title, string photo, uint128 cost, uint8 quantity) {
        cnx.editPrize(id, title, photo, cost, quantity);
    }

    function exchangePrize(uint256 id) {
        cnx.exchangePrize(id);
    }
}
