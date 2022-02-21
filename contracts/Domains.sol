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
    mapping(string => address) domains;
    mapping(string => string) records;

    string public tld;
    string svgPartOne =
        '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="270" height="270" preserveAspectRatio="none" viewBox="0 0 270 270"> <g mask="url(&quot;#SvgjsMask1015&quot;)" fill="none"> <path d="M305.125,237.641L81.562,368.318l67.566-197.296c6.586-19.231,26.932-34.817,45.45-34.817h290.569c18.518,0,28.189,15.586,21.604,34.817L439.185,368.318L305.125,237.641Z" transform="matrix(.248995-.001612 0.001393 0.215194 83.812136 190.268775)" fill="#b9c5c6"/><path d="M439.388,369.591c-.088.102-.202.173-.295.272-9.446,13.303-25.008,22.793-39.54,22.793h-295.115c-1.107,0-2.043-.27-3.087-.377h-.429c-.107-.014-.176-.074-.282-.088-6.812-.869-12.169-3.914-15.634-8.616-.065-.088-.178-.129-.243-.217l.074-.047c-.809-1.133-1.681-2.223-2.269-3.524-1.377-3.048-2.124-6.53-2.163-10.313-.011-.03-.03-.052-.034-.085l.041-.027c-.023-3.769,198.015-126.246,198.015-126.246c24.57-15.234,34.783-14.997,49.217,0c0,0,114.346,122.576,111.676,126.397l.068.078Z" transform="matrix(.248995-.001612 0.001797 0.277516 85.348321 165.430368)" fill="#96a9b2"/><path d="M167.814,144.631c5.942-4.166,15.793-7.974,23.306-8.773l297.738-.011c6.984.81,13.209,0,17.315,8.783s2.92,13.753,2.92,13.753L314.09,282.712c-24.191,14.999-34.247,14.766-48.458,0L155.609,158.187c0,0,6.263-9.39,12.205-13.556Z" transform="matrix(.248995-.001612 0.001393 0.215194 82.123452 193.225841)" fill="#dce2e2"/><path d="M114.107,203.102h-95.998c-8.008,0-14.5-6.492-14.5-14.5s6.492-14.5,14.5-14.5h95.998c8.008,0,14.5,6.492,14.5,14.5s-6.492,14.5-14.5,14.5Zm-13.041,48.469c0-8.008-6.492-14.5-14.5-14.5h-68.457c-8.008,0-14.5,6.492-14.5,14.5s6.492,14.5,14.5,14.5h68.457c8.009,0,14.5-6.492,14.5-14.5Zm-22.205,62.97c0-8.008-6.492-14.5-14.5-14.5h-46.252c-8.008,0-14.5,6.492-14.5,14.5s6.492,14.5,14.5,14.5h46.251c8.009,0,14.501-6.492,14.501-14.5Z" transform="matrix(.317519-.002056 0.001759 0.271661 63.219869 179.018579)" fill="#ffb636"/><rect width="270" height="270" x="0" y="0" fill="#0e2a47"></rect> <path d="M0,108.348C23.31,111.262,48.633,119.063,69.04,107.428C89.602,95.705,99.638,71.116,105.519,48.189C110.83,27.484,104.365,6.564,100.298,-14.421C96.434,-34.361,95.698,-56.047,82.352,-71.358C69.02,-86.653,48.426,-93.357,28.44,-96.856C9.885,-100.105,-7.954,-93.424,-26.551,-90.426C-48.209,-86.935,-73.014,-91.942,-89.785,-77.799C-106.971,-63.305,-110.112,-38.523,-114.291,-16.433C-118.634,6.523,-125.076,31.465,-114.385,52.238C-103.791,72.823,-79.555,81.252,-58.77,91.448C-40.091,100.611,-20.644,105.767,0,108.348" fill="#0b2239"></path> <path d="M270 402.28700000000003C294.973 406.456 321.09000000000003 396.193 341.286 380.923 360.78499999999997 366.18 373.679 343.655 379.076 319.813 383.946 298.3 374.836 277.11 369.64 255.674 364.954 236.339 362.265 216.329 350.166 200.536 337.63 184.172 319.825 173.18200000000002 300.649 165.618 280.082 157.506 258.146 151.519 236.43099999999998 155.675 213.576 160.049 190.122 170.176 176.875 189.30700000000002 163.97199999999998 207.941 166.57999999999998 232.612 167.476 255.25900000000001 168.24099999999999 274.596 173.98399999999998 292.579 181.666 310.341 189.497 328.448 198.85899999999998 345.204 212.527 359.43 229.426 377.02 245.941 398.27099999999996 270 402.28700000000003" fill="#113255"></path> </g> <defs> <mask id="SvgjsMask1015"> <rect width="270" height="270" fill="#ffffff"></rect> </mask> </defs> <text x="32.5" y="231" font-size="27" fill="#fff" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = "</text></svg>";

    constructor(string memory _tld) ERC721("Cyber Name Service", "CNS") {
        tld = _tld;
        console.log("TLD is:", tld);
    }

    function registerDomain(string calldata name) public payable {
        require(domains[name] == address(0), "The domain is already taken!");
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
                    '"description": "A domain on the Cyber name service"',
                    '"image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(finalSvg)),
                    '", "length": ',
                    strLen,
                    "}"
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

        console.log(
            "%s has registered a domain! by name %s.%s",
            msg.sender,
            name,
            tld
        );
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

    function price(string calldata name) public pure returns (uint256) {
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
