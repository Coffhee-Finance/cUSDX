// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

// ============ Internal Imports ============
import {TokenRouter} from "./libs/TokenRouter.sol";
import {TokenMessage} from "./libs/TokenMessage.sol";
import {MailboxClient} from "../client/MailboxClient.sol";

// ============ External Imports ============
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Hyperlane ERC20 Token Collateral that wraps USDX on the destination chain-Arbitrum.
 Tokens are locked inside contract on BNB Chain.
 * @author Abacus Works
 */
contract HypERC20Collateral is TokenRouter {
    using SafeERC20 for IERC20;

    IERC20 public immutable wrappedToken;

    /**
     * @notice Constructor
     * @param Address of USDX on BNB Chain to keep as collateral
     */
    constructor(address usdx, address _mailbox) TokenRouter(_mailbox) {
        require(Address.isContract(erc20), "HypERC20Collateral: invalid token");
        wrappedToken = IERC20(usdx);
    }

    function initialize(
        address _hook,
        address _interchainSecurityModule,
        address _owner
    ) public virtual initializer {
        _MailboxClient_initialize(_hook, _interchainSecurityModule, _owner);
    }

    function balanceOf(
        address _account
    ) external view override returns (uint256) {
        return wrappedToken.balanceOf(_account);
    }

    /**
     * @dev Transfers `_amount` of `wrappedToken` from `msg.sender` to this contract.
     * @inheritdoc TokenRouter
     */
    function _transferFromSender(
        uint256 _amount
    ) internal virtual override returns (bytes memory) {
        wrappedToken.safeTransferFrom(msg.sender, address(this), _amount);
        return bytes("USDX"); // no metadata
    }

    /**
     * @dev Transfers `_amount` of `wrappedToken` from this contract to `_recipient`.
     * @inheritdoc TokenRouter
     */
    function _transferTo(
        address _recipient,
        uint256 _amount,
        bytes calldata // no metadata
    ) internal virtual override {
        wrappedToken.safeTransfer(_recipient, _amount);
    }
}
