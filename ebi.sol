// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

/**
 * CMPT789 Project - Blockchain & Smart contracts
 * The contract uses OpenZeppelin Contract skeleton and modified to meet the need of our project.
 */

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
/**
 * To use newest version of the extensions, please replace the import file with the following line:
 * import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 * import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
 * import "@openzeppelin/contracts/utils/Context.sol";
 */

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

struct Rational {
    uint8 numerator;
    uint8 denominator;
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => bool) internal _merchantList; 

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) internal _thirdPartyList;

    address[] private _pendingMerchants;
    address[] private _pendingThirdParties;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private _owner;
    uint256 private _maxAllowance;

    Rational private handlingRate;
    Rational private tipRate;

    /**
     * Modifier to determine if the address is in the merchant address list.
     */
    modifier isMerchant(address _address) {
        require(_merchantList[_address], "You need to be a merchant");
        _;
    }

    /**
     * Modifier to determine if the address is in the third party address list.
     */
    modifier isThirdParty(address _address) {
        require(_thirdPartyList[_address], "You need to be an authorized third-party.");
        _;
    }

    /**
     * Modifier to determine if the address is in the contract owner.
     */
    modifier isOwner(address _address) {
        require(_address == _owner, "You need to be the owner.");
        _;
    }

    /**
     * Modifier to determine if the address is NOT in the merchant address list.
     */
    modifier notMerchant(address _address) {
        require(!_merchantList[_address], "You are already a merchant.");
        _;
    }

    /**
     * Modifier to determine if the address is NOT in the third party address list.
     */
    modifier notThirdParty(address _address) {
        require(!_thirdPartyList[_address], "You are already a third party.");
        _;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for {decimals} you should overload it.
     *
     * Define the contract maker as the {owner}.
     *
     * Define the {handlingRate} and {tipRate} that would be used when calculating the taxes and tips.
     */
    constructor(string memory name_, string memory symbol_, uint8 handlingRateNum, uint8 tipRateNum) {
        _name = name_;
        _symbol = symbol_;
        _owner = _msgSender();
        _maxAllowance = 100 * 10 ** decimals();
        handlingRate.denominator = 100;
        handlingRate.numerator = handlingRateNum;
        tipRate.denominator = 100;
        tipRate.numerator = tipRateNum;        
    }
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for display purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     *
     * Define the total number of tokens.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     * 
     * Return the balance of the specific account.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    /**
     * Return the defined handling rate.
     */
    function getHandlingRate() public view returns(uint8){
        return handlingRate.numerator;
    }

    /**
     * Return the defined tip rate.
     */
    function getTipRate() public view returns(uint8){
        return tipRate.numerator;
    }
    
    /**
     * Re-define the handling rate.
     */
    function setHandlingRate(uint8 _rate) public isOwner(_msgSender()) {
        handlingRate.numerator = _rate;
    }
    
    /**
     * Re-define the tip rate.
     */
    function setTipRate(uint8 _rate) public isOwner(_msgSender()) {
        tipRate.numerator = _rate;
    }
    
    /**
     * Return all the merchants in the pending list. 
     */
    function getPendingMerchants() public view returns(address[] memory) {
        return _pendingMerchants;
    }
    
    /**
     * Return all the third parties in the pending list. 
     */
    function getPendingThridParties() public view returns(address[] memory) {
        return _pendingThirdParties;
    }
    
    /**
     * Add all the merchants in the pending list to the merchant list. (only contract owner is allowed to execute this function)
     */
    function addAllPendingMerchants() public isOwner(_msgSender()) {
        for(uint i=0; i <_pendingMerchants.length; ++i ) {
            if (!_merchantList[_pendingMerchants[i]]){
                _merchantList[_pendingMerchants[i]] = true;
            }
        }
        delete _pendingMerchants;
    }
    
    /**
     * Add all the third parties in the pending list to the third party list. (only contract owner is allowed to execute this function)
     */
    function addAllPendingThirdParties() public isOwner(_msgSender()) {
        for(uint i=0; i<_pendingThirdParties.length; ++i) {
            if(!_thirdPartyList[_pendingThirdParties[i]]) {
                _thirdPartyList[_pendingThirdParties[i]] = true;
            }
        }

        delete _pendingThirdParties;
    }

    /**
     * Add new merchant to the merchant list (only contract owner is allowed to execute this function).
     */
    function addMerchant(address _addressToMerchant) public isOwner(_msgSender()){
        _merchantList[_addressToMerchant] = true;
    }
    
    /**
     * Verify if the given account is merchant and return true or false value. 
     */
    function verifyMerchant(address _merchantAddress) public view returns(bool) {
        bool merchantIsWhitelisted = _merchantList[_merchantAddress];
        return merchantIsWhitelisted;
    }
    
    /**
     * Add new third party to the third party list (only contract owner is allowed to execute this function).
     */
    function addThirdParty(address _addressToThirdParty) public isOwner(_msgSender()){
        _thirdPartyList[_addressToThirdParty] = true;
    }
    
    /**
     * Verify if the given account is third party and return true or false value. 
     */
    function verifyThirdParty(address _thirdPartyAddress) public view returns(bool) {
        bool thirdPartyIsWhitelisted = _thirdPartyList[_thirdPartyAddress];
        return thirdPartyIsWhitelisted;
    }
    
    /**
     * Remove the merchant from the merchant list. (only contract owner is allowed to execute this function)
     */
    function removeMerchant(address _merchantAddress) public isOwner(_msgSender()) {
        _merchantList[_merchantAddress] = false;
    }
    
    /**
     * Remove the third party from the third party list. (only contract owner is allowed to execute this function)
     */
    function removeThirdParty(address _thirdPartyAddress) public isOwner(_msgSender()) {
        _thirdPartyList[_thirdPartyAddress] = false;
    }
    
    /**
     * Request to become a merchant account. An existing merchant account cannot request this function.
     */
    function requestMerchant() public notMerchant(_msgSender()) {
        _pendingMerchants.push(_msgSender());
    }
    
    /**
     * Request to become a third party account. An existing third party account cannot request this function.
     */
    function requestThirdParty() public notThirdParty(_msgSender()) {
        _pendingThirdParties.push(_msgSender());
    }

    /**
     * Return the defined maximum allowance a user can authorize a third party to spend.
     */
    function getMaxAllowance() public view returns(uint256) {
        return _maxAllowance;
    }
    
    /**
     * Re-define maximum allowance. (only contract owner is allowed to execute this function)
     */
    function setMaxAllowance(uint256 maxAllowance) public isOwner(_msgSender()) {
        _maxAllowance = maxAllowance;
    }

    /**
     * Increase maximum allowance by certain value. (only contract owner is allowed to execute this function)
     */
    function increaseMaxAllowance(uint256 addedAmount) public isOwner(_msgSender()) {
        _maxAllowance = _maxAllowance + addedAmount;
    }

    /**
     * Deduct maximum allowance by certain value. (only contract owner is allowed to execute this function)
     */
    function decreaseMaxAllowance(uint256 subtractedValue) public isOwner(_msgSender()) {
        require(_maxAllowance >= subtractedValue, "ERC20: Max allowance cannot below zero.");
        unchecked {
            _maxAllowance = _maxAllowance - subtractedValue;
        }
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * 
     * If the transaction is to the verified merchant list or verified third party list, 
     * we will treat it as purchase transaction and thus deduct taxes.
     * 
     * Otherwise it will probably be some token transaction between users and we will not 
     * deduct taxes from the sender.
     *
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();
        uint256 fromBalance = _balances[from];
        uint256 handlingFee = handlingRate.numerator*amount / handlingRate.denominator;
        uint256 totalAmount = amount + handlingFee;
        
        // if the transfer is to the merchant or thrid party, we treat it as a purchase transaction and collect tax
        if (verifyMerchant(to) || verifyThirdParty(to)) {
            require(fromBalance >= totalAmount, "ERC20: transfer amount exceeds balance");
            // transfer original item value to the merchant
            _transfer(from, to, amount);
            // transfer tax to the contract owner for tax calculation
            _transfer(from, _owner, handlingFee);
        } else {
            // otherwise we will only treat it as a transaction between users and will not collect tax
            _transfer(from, to, amount);
        }
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `amount` cannot be more than the defined maximum allowance.
     *
     * In this case, a user can only authorize a verified third party.
     */
    function approve(address thirdParty, uint256 amount) public override returns (bool) {
        if (verifyThirdParty(thirdParty)) {
            // Only allow for trusted third-party in the whitelist.
            require(amount <= getMaxAllowance(), "ERC20: Amount exceeds maximum allowance.");
            unchecked {
                _approve(_msgSender(), thirdParty, amount);
            }
            return true;
        }
        return false;
    }

    /**
     *
     * Requirements:
     *
     * - `thirdParty` cannot be the zero address and have to be listed in the third party list.
     * - the new balance cannot be more than the defined maximum allowance.
     *
     * In this case, a user can only increase the allowance for a verified third party.
     */
    function increaseAllowance(address thirdParty, uint256 addedAmount) public virtual returns (bool) {
        if (verifyThirdParty(thirdParty)) {
            // Only allow for trusted third-party in the whitelist.
            uint256 newAllowance = allowance(_msgSender(), thirdParty) + addedAmount;
            require(newAllowance <= getMaxAllowance(), "ERC20: Amount exceeds maximum allowance.");
            unchecked {
                _approve(_msgSender(), thirdParty, newAllowance);
            }
            return true;
        }
        return false;
    }
    
    /**
     *
     * Requirements:
     *
     * - `thirdParty` cannot be the zero address and have to be listed in the third party list.
     * - the new balance cannot be less than zero.
     *
     * In this case, a user can only decrease the allowance for a verified third party.
     */
    function decreaseAllowance(address thirdParty, uint256 subtractedValue) public virtual returns (bool) {
        if (verifyThirdParty(thirdParty)) {
            // Only allow for trusted third-party in the whitelist.
            uint256 currentAllowance = allowance(_msgSender(), thirdParty);
            require(currentAllowance >= subtractedValue, "ERC20: Decreased allowance below zero");
            unchecked {
                _approve(_msgSender(), thirdParty, currentAllowance - subtractedValue);
            }
            return true;
        }
        return false;
    }


    /**
     * Generate token when user purchase token in-store.
     * 
     * The function can only executed by a verified third party.
     * Also to avoid possible malicious activity, the function prevents a merchant to call this function
     * and generate tokens for another merchant account.
     */
    function mint(address account, uint256 amount) public virtual isMerchant(_msgSender()) returns (bool){
        require(!verifyMerchant(account), "ERC20: You can not mint to a machant account");
        unchecked {
            _mint(account, amount);
        }
        return true;
    }

    /**
     * Payable function to let user generate token directly at a fixed exchange rate at 1:1000 using Ether.
     */
    function purchaseToken() public payable returns (bool){
        require(msg.value > 0, "You need to buy more than 0 tokens");
        unchecked {
            _mint(_msgSender(), msg.value * 1000);
        }
        return true;
    }

    /**
     * Burn token from merchant account. This can only execute from a verified merchant account.
     *
     * This is normally used to clear tokens after certain accounting procedure. (i.e. monthly ledger check)
     * The aim is to clear extra token generated and used after a purchase event.
     *
     * For example if we set the value for CAD:EBI to 1:1, then after user purchase 100 EBI token and spend them
     * at store, the store will have both 100CAD and 100EBI. Then during the ledger check we probably want to 
     * destory these 100EBI since they are already being 'spent' and we already received 100CAD at the very beginning.
     *
     * By doing this, the amount of EBI will then be able to reflect the correct value.
     */
    function burn(address account, uint256 amount) public virtual isMerchant(_msgSender()) returns (bool){
        require(!verifyMerchant(account), "ERC20: You can not burn from a machant account");
        unchecked {
            _burn(account, amount);
        }
        return true;
    }

    /**
     * Withdraw Ether from the contract. This can only execute from the contract owner.
     */
    function withdrawEther(address payable to, uint256 amount) public isOwner(_msgSender()) returns (bool){
        require(address(this).balance >= amount, "ERC20: Not enough balance to withdraw");
        unchecked{
            to.transfer(amount);
        }
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     *
     * Here we modified it to collect both tips and taxes. Also the function can only execute by a verified third party.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override isThirdParty(_msgSender()) isMerchant(to) returns (bool) {
        address spender = _msgSender();
        
        uint256 tips = (tipRate.numerator * amount) / tipRate.denominator;
        uint256 handlingFee = (handlingRate.numerator * amount) / handlingRate.denominator;

        // First we check if the user authorized enough allowance for the third party
        _spendAllowance(from, spender, amount+tips+handlingFee);
        // then we transfer the original amount to the merchant
        _transfer(from, to, amount);
        // and calculate tips and send to the third party
        _transfer(from, spender, tips);
        // at last we calculate tax and send it to the contract owner
        _transfer(from, _owner, handlingFee);
        return true;
    }


    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
