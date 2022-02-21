// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import {StringUtils} from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains {
    mapping(string => address) domains;
    mapping(string => string) records;

    string public tld;

    constructor(string memory _tld) payable {
        tld = _tld;
        console.log("TLD is:", tld);
    }

    function registerDomain(string calldata name) public payable {
        require(domains[name] == address(0), "The domain is already taken!");
        uint256 _price = price(name);
        require(msg.value > _price, "Not enough Matic to buy the domain");
        domains[name] = msg.sender;
        console.log("%s has registered a domain!", msg.sender);
    }

    function setRecord(string calldata name, string calldata record) public {
        require(
            domains[name] == msg.sender,
            "User setting record is not owner!"
        );
        records[name] = record;
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function price(string calldata name) public view returns (uint256) {
        uint256 len = StringUtils.strlen(name);
        require(len > 0, "The domain length should be greater than zero!");
        if (len == 3) {
            return 3 * 10**17;
        } else if (len == 4) {
            return 2 * 10**17;
        } else {
            return 1 * 10**17;
        }
    }
}
