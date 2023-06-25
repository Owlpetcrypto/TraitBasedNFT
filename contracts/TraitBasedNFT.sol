//0x4E17d4fb585C13AdfbdFD60fCb583cc511DfbB5a
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TraitBasedNFT is ERC721, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    error PreSaleNotActive();
    error PublicSaleNotActive();
    error NoContracts();

    mapping(uint256 => EnumerableSet.UintSet) private traitToTokenIds;
    mapping(uint256 => bool) public mintedTokens;
    uint256[] public availableTokenIds;
    uint256[] public traitList;
    mapping(address => uint256) public userMintCount;

    string public _baseTokenURI;

    bool public presaleActive;
    bool public publicSaleActive;
    uint256 public maxSupply = 7;
    uint256 public maxMint = 6;
    uint256 public price_1 = 0.01 ether;
    uint256 public price_3 = 0.02 ether;
    uint256 public price_6 = 0.03 ether;

    string public baseTokenUri;
    bytes32 public presaleMerkleRoot;

    uint256[] public trait1 = [1, 6, 14];
    // ,51,75,102,113,135,137,157,195,201,210,213,215,241,244,267,268,278,300,341,355,358,363,379,391,404,430,435,478,517,523,525,548,559,573,584,589,598,618,687,695,714,725,730,765,785,814,825,834,904,940,942,993,1031,1077,1088,1102,1111,1128,1158,1160,1175,1194,1199,1224,1263,1273,1309,1342,1345,1377,1379,1416,1419,1425,1449,1452,1464,1471,1472,1484,1507,1510,1532,1533,1560,1572,1598,1604,1610,1637,1640,1689,1700,1705,1706,1707,1734,1736,1754,1761,1776,1811,1813,1863,1882,1888,1892,1901,1910,1917,1929,1959,2003,2057,2076,2086,2103,2116,2137,2155,2157,2191,2257,2258,2260,2266,2270,2273,2299,2305,2337,2406,2428,2442,2460,2478,2487,2499];
    uint256[] public trait2 = [3, 26, 33];

    // ,44,72,105,150,253,284,309,320,411,456,568,569,632,633,748,750,773,958,974,989,1002,1005,1009,1039,1054,1114,1125,1156,1162,1186,1220,1267,1307,1362,1420,1463,1481,1537,1579,1611,1670,1728,1751,1792,1841,1852,1869,1873,1899,1987,2013,2080,2132,2162,2171,2177,2184,2193,2199,2213,2226,2246,2392,2397,2466,2476];

    constructor() ERC721("TraitBasedNFT", "TNFT") {
        _baseTokenURI = "https://nftstorage.link/ipfs/bafybeiemwrvmq4mxmzyv5yx5u4thrdmxqvzh2qzccd4o6sm4zitk4qqnfu/";

        uint256[] memory traitCounts = new uint256[](27);
        traitCounts[0] = trait1.length;
        traitCounts[1] = trait2.length;
        // Add more trait counts here...

        for (uint256 i = 0; i < trait1.length; i++) {
            availableTokenIds.push(trait1[i]);
            traitToTokenIds[1].add(trait1[i]);
        }

        for (uint256 i = 0; i < trait2.length; i++) {
            availableTokenIds.push(trait2[i]);
            traitToTokenIds[2].add(trait2[i]);
        }
    }

    modifier callerIsUser() {
        if (msg.sender != tx.origin) revert NoContracts();
        _;
    }

    function getTraitTokenCount(uint256 trait) public view returns (uint256) {
        return traitToTokenIds[trait].length();
    }

    function getTraitTokenByIndex(uint256 trait, uint256 index)
        public
        view
        returns (uint256)
    {
        return traitToTokenIds[trait].at(index);
    }

    function setBaseTokenURI(string memory newBaseTokenURI) public onlyOwner {
        _baseTokenURI = newBaseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        pure
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "https://nftstorage.link/ipfs/bafybeiemwrvmq4mxmzyv5yx5u4thrdmxqvzh2qzccd4o6sm4zitk4qqnfu/",
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    function togglePresale() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function setPresaleMerkleRoot(bytes32 _presaleMerkleRoot)
        external
        onlyOwner
    {
        presaleMerkleRoot = _presaleMerkleRoot;
    }

    function setPrice_1(uint256 _price_1) external onlyOwner {
        price_1 = _price_1;
    }

    function setPrice_3(uint256 _price_3) external onlyOwner {
        price_3 = _price_3;
    }

    function setPrice_6(uint256 _price_6) external onlyOwner {
        price_6 = _price_6;
    }

    function mintWithTraitOG(
        uint256 _trait,
        uint256 _quantity,
        bytes32[] calldata _proof
    ) external payable callerIsUser {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );
        require(
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not on the whitelist"
        );

        if (!presaleActive) revert PreSaleNotActive();

        uint256 price;
        uint256 previousTransactions = userMintCount[msg.sender];

        if (previousTransactions == 0) {
            price = price_1;
        } else if (previousTransactions == 1) {
            price = 0;
        } else if (previousTransactions >= 2 && _quantity == 1) {
            price = price_1;
        } else if (previousTransactions >= 2 && _quantity <= 3) {
            price = price_3;
        } else if (previousTransactions >= 2) {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);
            _mint(msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function mintWithTraitPresale(
        uint256 _trait,
        uint256 _quantity,
        bytes32[] calldata _proof
    ) external payable callerIsUser {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );
        require(
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not on the whitelist"
        );

        if (!presaleActive) revert PreSaleNotActive();

        uint256 price;

        if (_quantity == 1) {
            price = price_1;
        } else if (_quantity <= 3) {
            price = price_3;
        } else {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);
            _mint(msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function mintWithTraitPublic(uint256 _trait, uint256 _quantity)
        external
        payable
        callerIsUser
    {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );

        if (!publicSaleActive) revert PublicSaleNotActive();

        uint256 price;
        if (_quantity == 1) {
            price = price_1;
        } else if (_quantity <= 3) {
            price = price_3;
        } else {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);

            _safeMint(msg.sender, tokenId);

            emit Transfer(address(0), msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function _random(uint256 _limit) private view returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            _limit;
    }

    function isValid(address _user, bytes32[] calldata _proof)
        external
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(_user))
            );
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
