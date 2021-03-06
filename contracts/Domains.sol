// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import {StringUtils} from "./libraries/StringUtils.sol";
import {Base64} from "./libraries/Base64.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(uint256 => string) public names;

    address payable public owner;

    string public tld;
    string svgPartOne =
        '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="270" height="270" preserveAspectRatio="none" viewBox="0 0 270 270"> <g mask="url(&quot;#SvgjsMask1015&quot;)" fill="none"> <rect width="270" height="270" x="0" y="0" fill="#0e2a47"></rect> <path d="M0,108.348C23.31,111.262,48.633,119.063,69.04,107.428C89.602,95.705,99.638,71.116,105.519,48.189C110.83,27.484,104.365,6.564,100.298,-14.421C96.434,-34.361,95.698,-56.047,82.352,-71.358C69.02,-86.653,48.426,-93.357,28.44,-96.856C9.885,-100.105,-7.954,-93.424,-26.551,-90.426C-48.209,-86.935,-73.014,-91.942,-89.785,-77.799C-106.971,-63.305,-110.112,-38.523,-114.291,-16.433C-118.634,6.523,-125.076,31.465,-114.385,52.238C-103.791,72.823,-79.555,81.252,-58.77,91.448C-40.091,100.611,-20.644,105.767,0,108.348" fill="#0b2239"></path> <path d="M270 402.28700000000003C294.973 406.456 321.09000000000003 396.193 341.286 380.923 360.78499999999997 366.18 373.679 343.655 379.076 319.813 383.946 298.3 374.836 277.11 369.64 255.674 364.954 236.339 362.265 216.329 350.166 200.536 337.63 184.172 319.825 173.18200000000002 300.649 165.618 280.082 157.506 258.146 151.519 236.43099999999998 155.675 213.576 160.049 190.122 170.176 176.875 189.30700000000002 163.97199999999998 207.941 166.57999999999998 232.612 167.476 255.25900000000001 168.24099999999999 274.596 173.98399999999998 292.579 181.666 310.341 189.497 328.448 198.85899999999998 345.204 212.527 359.43 229.426 377.02 245.941 398.27099999999996 270 402.28700000000003" fill="#113255"></path> </g> <defs> <mask id="SvgjsMask1015"> <rect width="270" height="270" fill="#ffffff"></rect> </mask> </defs> <text x="32.5" y="231" font-size="27" fill="#fff" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = "</text></svg>";

    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

    constructor(string memory _tld)
        payable
        ERC721("Cyber Name Service", "CNS")
    {
        owner = payable(msg.sender);
        tld = _tld;
        console.log("TLD is:", tld);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "User is not owner!");
        _;
    }

    function registerDomain(string calldata name) public payable {
        if (domains[name] != address(0)) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);
        uint256 _price = price(name);
        require(msg.value > _price, "Not enough Matic to buy the domain");

        /**
            safemint and set the necessary records on-chain
         */
        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(_name);
        string memory strLen = Strings.toString(length);

        string memory json = Base64.encode(
            bytes(
                abi.encodePacked(
                    '{"name": "',
                    _name,
                    '", "description": "A domain system for Cyber name service", "image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(finalSvg)),
                    '","length":"',
                    strLen,
                    '"}'
                )
            )
        );
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        ); // sets the finalTokenUri NFT metadata

        console.log(
            "\n--------------------------------------------------------"
        );
        console.log("Final tokenURI", finalTokenUri);
        console.log(
            "--------------------------------------------------------\n"
        );
        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri); // attach the recordId with domain NFT metadata

        domains[name] = msg.sender; // attach the string to domain owner address
        _tokenIds.increment(); // increment recordId
        names[newRecordId] = name;

        console.log(
            "%s has registered a domain! by name %s.%s",
            msg.sender,
            name,
            tld
        );
    }

    function setRecord(string calldata name, string calldata record) public {
        if (domains[name] != msg.sender) revert Unauthorized();
        records[name] = record;
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function price(string calldata name) public pure returns (uint256) {
        uint256 len = StringUtils.strlen(name);
        if (len == 3) {
            return 3 * 10**17;
        } else if (len == 4) {
            return 2 * 10**17;
        } else {
            return 1 * 10**17;
        }
    }

    function valid(string calldata name) public pure returns (bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
    }

    function withdraw() public OnlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }

    function getAllNames() public view returns (string[] memory) {
        console.log("getting all names....");
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = names[i];
        }

        return allNames;
    }
}
