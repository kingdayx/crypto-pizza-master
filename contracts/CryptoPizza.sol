// SPDX-License-Identifier: GNU GPL v.3
pragma solidity ^0.6.2;

// Imports symbols from other files into the current contract.
// In this case, a series of helper contracts from OpenZeppelin.
// Learn more: https://solidity.readthedocs.io/en/v0.6.2/layout-of-source-files.html#importing-other-source-files

// IERC721 is the ERC721 interface that we'll use to make CryptoPizza ERC721 compliant
// More about ERC721: https://eips.ethereum.org/EIPS/eip-721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// IERC721Receiver must be implemented to accept safe transfers.
// It is included on the ERC721 standard
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// ERC165 is used to declare interface support for IERC721
// More about ERC165: https://eips.ethereum.org/EIPS/eip-165
import "@openzeppelin/contracts/introspection/ERC165.sol";
// SafeMath will be used for every math operation
import "@openzeppelin/contracts/math/SafeMath.sol";
// Address will provide functions such as .isContract verification
import "@openzeppelin/contracts/utils/Address.sol";

// The `is` keyword is used to inherit functions and keywords from external contracts.
// In this case, `CryptoPizza` inherits from the `IERC721` and `ERC165` contracts.
// Learn more: https://solidity.readthedocs.io/en/v0.6.2/contracts.html#inheritance
contract CryptoPizza is IERC721, ERC165 {
    // Uses OpenZeppelin's SafeMath library to perform arithmetic operations safely.
    // Learn more: https://docs.openzeppelin.com/contracts/3.x/api/math#SafeMath
    using SafeMath for uint256;
    using Address for address;

    // Constant state variables in Solidity are similar to other languages
    // but you must assign from an expression which is constant at compile time.
    // Learn more: https://solidity.readthedocs.io/en/v0.6.2/contracts.html#constant-state-variables
    uint256 constant dnaDigits = 10;
    uint256 constant dnaModulus = 10**dnaDigits;
    address owner;

    // ERC165 identifier for the ERC721 interface got from
    // bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Struct types let you define your own type
    // Learn more: https://solidity.readthedocs.io/en/v0.6.2/types.html#structs
    struct Pizza {
        string name;
    }

    constructor() public {
        owner == msg.sender;
    }


    // Creates an empty array of Pizza structs
    Pizza[] public pizzas;

    // Mapping from id of Pizza to its owner's address
    mapping(uint256 => address) public pizzaToOwner;

    // Mapping from owner's address to number of owned token
    mapping(address => uint256) public ownerPizzaCount;

    // Mapping to validate that dna is not already taken
    mapping(uint256 => bool) public dnaPizzaExists;

    // Mapping to validate that name is not already taken
    mapping(string => bool) public namePizzaExists;

    // Mapping from token ID to approved address
    mapping(uint256 => address) pizzaApprovals;

    // You can nest mappings, this example maps owner to operator approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // Check if Pizza is unique and doesn't exist yet
    modifier isUnique(string memory _name) {
        require(
            !namePizzaExists[_name],
            "Pizza with such name already exists."
        );
        _;
    }

  
    // Creates a random Pizza from string (name)
    function createRandomPizza(string memory _name) payable public {
         require(msg.value == 7100000000000000, "Insufficient ether received");
         _createPizza(_name);
        //  address payable feeRecipient = 0x2560dE277f434ceec031442dBBBDad9C18dF290D;
        //  feeRecipient.transfer(msg.value);
        }

    // Generates random DNA from string (name) and address of the owner (creator)
    function generateRandomDna(string memory _str, address _owner)
        public
        pure
        returns (
            // Functions marked as `pure` promise not to read from or modify the state
            // Learn more: https://solidity.readthedocs.io/en/v0.6.2/contracts.html#pure-functions
            uint256
        )
    {
        // Generates random uint from string (name) + address (owner)
        uint256 rand = uint256(keccak256(abi.encodePacked(_str))) +
            uint256(_owner);
        rand = rand.mod(dnaModulus);
        return rand;
    }

   

    // Internal function to create a random Pizza from string (name) and DNA
    function _createPizza(string memory _name)  public
        // The `internal` keyword means this function is only visible
        // within this contract and contracts that derive this contract
        // Learn more: https://solidity.readthedocs.io/en/v0.6.2/contracts.html#visibility-and-getters
        // `isUnique` is a function modifier that checks if the pizza already exists
        // Learn more: https://solidity.readthedocs.io/en/v0.6.2/structure-of-a-contract.html#function-modifiers
        isUnique(_name)
    {
        
        // Adds Pizza to array of Pizzas and get id
        pizzas.push(Pizza(_name));
        uint256 id = pizzas.length.sub(1);

        // Mark as existent pizza name and dna

        namePizzaExists[_name] = true;

        // Checks that Pizza owner is the same as current user
        // Learn more: https://solidity.readthedocs.io/en/v0.6.2/control-structures.html#error-handling-assert-require-revert-and-exceptions
        assert(pizzaToOwner[id] == address(0));

        // Maps the Pizza to the owner
        pizzaToOwner[id] = msg.sender;
        ownerPizzaCount[msg.sender] = ownerPizzaCount[msg.sender].add(1);
    }

    // Returns array of Pizzas found by owner
    function getPizzasByOwner(address _owner)
        public
        view
        returns (
            // Functions marked as `view` promise not to modify state
            // Learn more: https://solidity.readthedocs.io/en/v0.6.2/contracts.html#view-functions
            uint256[] memory
        )
    {
        // Uses the `memory` storage location to store values only for the
        // lifecycle of this function call.
        // Learn more: https://solidity.readthedocs.io/en/v0.6.2/introduction-to-smart-contracts.html#storage-memory-and-the-stack
        uint256[] memory result = new uint256[](ownerPizzaCount[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < pizzas.length; i++) {
            if (pizzaToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    // Returns count of Pizzas by address
    function balanceOf(address _owner)
        public
        override
        view
        returns (uint256 _balance)
    {
        return ownerPizzaCount[_owner];
    }

    // Returns owner of the Pizza found by id
    function ownerOf(uint256 _pizzaId)
        public
        override
        view
        returns (address _owner)
    {
        address owner = pizzaToOwner[_pizzaId];
        require(owner != address(0), "Invalid Pizza ID.");
        return owner;
    }

    /**
     * Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`;
     * otherwise, the transfer is reverted.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 pizzaId
    ) public override {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(from, to, pizzaId, "");
    }

    // Transfers Pizza and ownership to other address
    function transferFrom(
        address _from,
        address _to,
        uint256 _pizzaId
    ) public override {
        require(_from != address(0) && _to != address(0), "Invalid address.");
        require(_exists(_pizzaId), "Pizza does not exist.");
        require(_from != _to, "Cannot transfer to the same address.");
        require(
            _isApprovedOrOwner(msg.sender, _pizzaId),
            "Address is not approved."
        );

        ownerPizzaCount[_to] = ownerPizzaCount[_to].add(1);
        ownerPizzaCount[_from] = ownerPizzaCount[_from].sub(1);
        pizzaToOwner[_pizzaId] = _to;

        // Emits event defined in the imported IERC721 contract
        emit Transfer(_from, _to, _pizzaId);
        _clearApproval(_to, _pizzaId);
    }

    // Checks if Pizza exists
    function _exists(uint256 pizzaId) internal view returns (bool) {
        address owner = pizzaToOwner[pizzaId];
        return owner != address(0);
    }

    // Checks if address is owner or is approved to transfer Pizza
    function _isApprovedOrOwner(address spender, uint256 pizzaId)
        internal
        view
        returns (bool)
    {
        address owner = pizzaToOwner[pizzaId];
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (spender == owner ||
            getApproved(pizzaId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * Private function to clear current approval of a given token ID
     * Reverts if the given address is not indeed the owner of the token
     */
    function _clearApproval(address owner, uint256 _pizzaId) private {
        require(pizzaToOwner[_pizzaId] == owner, "Must be pizza owner.");
        require(_exists(_pizzaId), "Pizza does not exist.");
        if (pizzaApprovals[_pizzaId] != address(0)) {
            pizzaApprovals[_pizzaId] = address(0);
        }
    }

    // Approves other address to transfer ownership of Pizza
    function approve(address _to, uint256 _pizzaId) public override {
        require(
            msg.sender == pizzaToOwner[_pizzaId],
            "Must be the Pizza owner."
        );
        pizzaApprovals[_pizzaId] = _to;
        emit Approval(msg.sender, _to, _pizzaId);
    }

    // Returns approved address for specific Pizza
    function getApproved(uint256 _pizzaId)
        public
        override
        view
        returns (address operator)
    {
        require(_exists(_pizzaId), "Pizza does not exist.");
        return pizzaApprovals[_pizzaId];
    }

    /*
     * Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     */
    function setApprovalForAll(address to, bool approved) public override {
        require(to != msg.sender, "Cannot approve own address");
        operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    // Tells whether an operator is approved by a given owner
    function isApprovedForAll(address owner, address operator)
        public
        override
        view
        returns (bool)
    {
        return operatorApprovals[owner][operator];
    }

    /**
     * Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`;
     * otherwise, the transfer is reverted.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 pizzaId,
        bytes memory _data
    ) public override {
        transferFrom(from, to, pizzaId);
        require(
            _checkOnERC721Received(from, to, pizzaId, _data),
            "Must implmement onERC721Received."
        );
    }

    /**
     * Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 pizzaId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(
            msg.sender,
            from,
            pizzaId,
            _data
        );
        return (retval == _ERC721_RECEIVED);
    }

    // Burns a Pizza - destroys Token completely
    // The `external` function modifier means this function is
    // part of the contract interface and other contracts can call it
    function burn(uint256 _pizzaId) external {
        require(msg.sender != address(0), "Invalid address.");
        require(_exists(_pizzaId), "Pizza does not exist.");
        require(
            _isApprovedOrOwner(msg.sender, _pizzaId),
            "Address is not approved."
        );

        ownerPizzaCount[msg.sender] = ownerPizzaCount[msg.sender].sub(1);
        pizzaToOwner[_pizzaId] = address(0);
    }

    // Takes ownership of Pizza - only for approved users
    function takeOwnership(uint256 _pizzaId) public {
        require(
            _isApprovedOrOwner(msg.sender, _pizzaId),
            "Address is not approved."
        );
        address owner = ownerOf(_pizzaId);
        transferFrom(owner, msg.sender, _pizzaId);
    }

}
