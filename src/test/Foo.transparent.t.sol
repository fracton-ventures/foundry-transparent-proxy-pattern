// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Foo} from "../Foo.sol";
import {FooV2} from "../FooV2.sol";
import {ProxyAdmin} from "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Test} from "forge-std/Test.sol";

contract FooTest is Test {
    ProxyAdmin internal admin;
    TransparentUpgradeableProxy internal proxy;
    Foo internal foo;
    FooV2 internal fooV2;

    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment. Think of this like a JavaScript
    // `beforeEach` block
    function setUp() public {
        foo = new Foo();
        admin = new ProxyAdmin();
        proxy = new TransparentUpgradeableProxy(
            address(foo),
            address(admin),
            ""
        );
        foo = Foo(address(proxy));
        foo.initialize();
        require(foo.x() == 1, "x is not 1");
        foo.double();
        require(foo.x() == 2, "x is not 2");
        fooV2 = new FooV2();
    }

    // A simple unit test
    function testProxy() public {
        admin.upgrade(proxy, address(fooV2));
        fooV2 = FooV2(address(proxy));
        require(fooV2.x() == 2, "x is not 2");
        fooV2.triple();
        require(fooV2.x() == 6, "x is not 6");
    }

    // A failing unit test (function name starts with `testFail`)
    function testProxyFail() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(0));
        admin.upgrade(proxy, address(fooV2));
    }
}
