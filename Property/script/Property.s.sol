// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Property} from "../src/Property.sol";

contract PropertyScript is Script {
    Property public property;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        property = new Property();

        vm.stopBroadcast();
    }
}
