// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Property is ERC20 {
    constructor() ERC20("Property", "PROP") {
        _mint(msg.sender, 1000 * 10 ** decimals());
        owner = msg.sender;
        token = IERC20(address(this));
    }
    using SafeERC20 for IERC20;
    IERC20 public token;
    address public owner;
    struct PropertyInfo {
        uint8 id;
        string name;
        string location;
        uint256 price;
        bool isSold;
        uint256 description;
    }
    uint8 propertyID;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    mapping(address => uint256) public properties;
    event PurchaceSuccessful(address indexed buyer, uint256 price, string indexed name);

    PropertyInfo[] public propertyList;

    function createProperty(string memory _name, string memory _location, uint256 _price, uint256 _description) public onlyOwner() {
        propertyID++;
        PropertyInfo memory newProperty = PropertyInfo({
            id: propertyID,
            name: _name,
            location: _location,
            price: _price,
            isSold: false,
            description: _description
        });
        propertyList.push(newProperty);
    }

    function getAllProperties() public view returns (PropertyInfo[] memory) {
        return propertyList;
    }
    function deleteProperty(uint256 _id) external onlyOwner() {
        for(uint8 i; i < propertyList.length; i++) {
            if(propertyList[i].id == _id) {
                propertyList[i] = propertyList[propertyList.length - 1];
                propertyList.pop();
            }
         }
    }
    function purchaceProperty(uint256 _id, string memory _name) external {
        for(uint8 i; i < propertyList.length; i++) {
            if(propertyList[i].id == _id) {
                uint256 price = propertyList[i].price;
                require(!propertyList[i].isSold, "Property is already sold");
                require(token.allowance(msg.sender, address(this)) >= price, "Contract not approved to spend buyer tokens");
                token.safeTransferFrom(msg.sender, owner, price);
                propertyList[i].isSold = true;
                properties[msg.sender] = _id;
                emit PurchaceSuccessful(msg.sender, price, _name);
                return;
            }
        }
    }

    // Owner can withdraw any tokens accidentally sent to the contract itself
    function withdraw(uint256 _amount) external onlyOwner() {
        token.safeTransfer(owner, _amount);
    }


}
