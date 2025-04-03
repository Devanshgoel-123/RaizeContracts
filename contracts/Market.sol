// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

struct Outcome{
    string name;
    uint256 bought_shares;
}

struct Market{
   string name;
   uint256 market_id;
   string description;
   Outcome[2] outcomes;
   string category;
   string image;
   bool is_settled;
   bool is_active;
   uint64 deadline;
   Outcome winning_outcome;
   uint256 money_in_pool;
}

struct CryptoMarket{
    string name;
   uint256 market_id;
   string description;
   Outcome[2] outcomes;
   string category;
   string image;
   bool is_settled;
   bool is_active;
   uint64 deadline;
   Outcome winning_outcome;
   uint256 money_in_pool;
   uint8 conditions;
   uint64 price_key;
   uint128 amount;
}

struct SportsMarket{
   string name;
   uint256 market_id;
   string description;
   Outcome[2] outcomes;
   string category;
   string image;
   bool is_settled;
   bool is_active;
   uint64 deadline;
   Outcome winning_outcome;
   uint256 money_in_pool;
   uint64 api_event_id;
   bool is_home;
}

struct UserPosition{
    uint256 amount;
    bool has_claimed;
}

struct UserBet{
    Outcome outcome;
    UserPosition position;
}


//USA to india ke liye legal compliance how to bypass, can be done using b2b stablecoin payment rail. Rates, legal compliance will be their headache.


contract MarketFactory{
    address public admin;
    // IERC20 public USDC_TOKEN;
    // uint8 internal GLMR_USDT=137;
    address payable private treasuryWallet;
    uint8 PLATFORM_FEE=5;
    mapping (uint => Market) public markets;
    uint256 public markets_length;
    mapping (uint => CryptoMarket) public crypto_markets;
    uint256 public crypto_markets_length;
    mapping (uint => SportsMarket) public sport_markets;
    uint256 public sports_markets_length;
    mapping (address => mapping(uint8 => mapping (uint256 => mapping (uint256 => UserBet)))) public user_bets;
    // [userAddress][category][market_id][bet_number] -> userBet
    mapping (address => mapping (uint8 => mapping (uint256 => uint256) )) public num_bets;
    // [userAddress][category][market_id] -> num_bets
    constructor(address payable _treasuryWallet){
        admin=msg.sender;
        markets_length=0;
        crypto_markets_length=0;
        sports_markets_length=0;
        treasuryWallet=_treasuryWallet;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin,"Only the admin can call this function");
        _;
    }

    function create_share_tokens(string memory outcome1, string memory outcome2) internal pure returns (Outcome[2] memory) {
       Outcome[2] memory tokens=[
         Outcome({ name: outcome1, bought_shares: 0 }),
        Outcome({ name: outcome2, bought_shares: 0 })
       ];

       return tokens;
    }

    function create_market(
        string memory name, 
        string memory description,
        string memory outcome1,
        string memory outcome2,
        string memory category,
        string memory image,
        uint64 deadline
    ) public OnlyAdmin returns (bool){
          Outcome[2] memory outcomes = create_share_tokens(outcome1, outcome2);
          Market memory new_market=Market({
            name:name,
            description:description,
            outcomes:outcomes,
            is_settled:false,
            is_active:true,
            winning_outcome: Outcome({ name:"none", bought_shares: 0 }),
            money_in_pool:0,
            category:category,
            image:image,
            deadline:deadline,
            market_id:markets_length
          });
          markets[markets_length]=new_market;
          markets_length++;
          return true;
          //create event for market
    }

    function create_crypto_market(
        string memory name, 
        string memory description,
        string memory outcome1,
        string memory outcome2,
        string memory category,
        string memory image,
        uint64 deadline,
        uint8 conditions,
        uint64 priceKey,
        uint128 amount
    ) public OnlyAdmin{
        Outcome[2] memory outcomes = create_share_tokens(outcome1, outcome2);
        CryptoMarket memory new_crypto_market=CryptoMarket({
            name:name,
            description:description,
            outcomes:outcomes,
            is_settled:false,
            is_active:true,
            winning_outcome: Outcome({ name:"none", bought_shares: 0 }),
            money_in_pool:0,
            category:category,
            image:image,
            deadline:deadline,
            market_id:crypto_markets_length,
            conditions:conditions,
            price_key:priceKey,
            amount:amount
        });
        crypto_markets[crypto_markets_length]=new_crypto_market;
        crypto_markets_length++;
         //create event for crypto_market
    }

    function create_sports_market(
        string memory name, 
        string memory description,
        string memory outcome1,
        string memory outcome2,
        string memory category,
        string memory image,
        uint64 deadline,
        uint64 api_event_id,
        bool is_home
    ) public OnlyAdmin{
        Outcome[2] memory outcomes = create_share_tokens(outcome1, outcome2);
        SportsMarket memory new_sports_market=SportsMarket({
            name:name,
            description:description,
            outcomes:outcomes,
            is_settled:false,
            is_active:true,
            winning_outcome: Outcome({ name:"none", bought_shares: 0 }),
            money_in_pool:0,
            category:category,
            image:image,
            deadline:deadline,
            market_id:sports_markets_length,
            api_event_id:api_event_id,
            is_home:is_home
        });
        sport_markets[sports_markets_length]=new_sports_market;
        sports_markets_length++;

        //Emit event
    }
    
    function get_user_markets(address user) public view returns (Market[] memory){
    uint256 user_active_position_count=0;
    for (uint256 i = 0; i < markets_length; i++) {
        if (num_bets[user][2][i] > 0) {
            user_active_position_count++;
        }
    }
    Market[] memory userMarkets = new Market[](user_active_position_count);
    uint256 index = 0;
    for (uint256 i = 0; i < markets_length; i++) {
        if (num_bets[user][2][i] > 0) {
            userMarkets[index] = markets[i];
            index++;
        }
    }
    return userMarkets; 
    }

    function get_user_sports_markets(address user) public view returns (SportsMarket[] memory){
    uint256 user_active_position_count=0;
    for (uint256 i = 0; i < sports_markets_length; i++) {
        if (num_bets[user][0][i] > 0) {
            user_active_position_count++;
        }
    }
    SportsMarket[] memory userSportsMarkets = new SportsMarket[](user_active_position_count);
    uint256 index = 0;
    for(uint i=0;i < sports_markets_length;i++){
        if (num_bets[user][0][i] > 0) {
        userSportsMarkets[index] = sport_markets[i];
        index++;
        }
    }
    return userSportsMarkets; 
    }

    function get_user_crypto_markets(address user) public view returns (CryptoMarket[] memory){
    uint256 user_active_position_count=0;
    for (uint256 i = 0; i < crypto_markets_length; i++) {
        if (num_bets[user][1][i] > 0) {
            user_active_position_count++;
        }
    }
    CryptoMarket[] memory userCryptoMarkets = new CryptoMarket[](user_active_position_count);
    uint256 index = 0;
    for(uint i=0;i < sports_markets_length;i++){
        if (num_bets[user][1][i] > 0) {
        userCryptoMarkets[index] = crypto_markets[i];
        index++;
        }
    }
    return userCryptoMarkets; 
    }
    

    function settle_sports_market(
        uint256 market_id,
        uint8 winning_outcome
    ) public OnlyAdmin{
        require(market_id < sports_markets_length,"The market does not exist");
        SportsMarket storage currentMarket=sport_markets[market_id];
        require(currentMarket.is_settled == false, "Market has already been settled");
        require(currentMarket.is_active == true, "Market is not active");
        require(winning_outcome < 2, "Invalid outcome index");
        require(currentMarket.deadline<block.timestamp,"Market deadline has not expired yet, can't settle early Ser");
        // currentMarket.winning_outcome = currentMarket.outcomes[winning_outcome];
        for (uint256 i=0; i<2 ;i++){
            if(i==(winning_outcome)){
            currentMarket.winning_outcome=currentMarket.outcomes[i];
            } 
        }
        currentMarket.is_settled=true;
        currentMarket.is_active=false;

        //Emit event
    }

   function settle_crypto_market_manually(
        uint256 market_id,
        uint8 winning_outcome
    ) public OnlyAdmin{
        require(market_id < crypto_markets_length,"The market does not exist");
        CryptoMarket storage currentMarket=crypto_markets[market_id];
        require(currentMarket.is_settled == false, "Market has already been settled");
        require(currentMarket.is_active == true, "Market is not active");
        for (uint256 i=0; i<2 ;i++){
            if(i==(winning_outcome)){
            currentMarket.winning_outcome=currentMarket.outcomes[i];
            } 
        }
        currentMarket.is_settled=true;
        currentMarket.is_active=false;

        //Emit Event
    }

   function settle_market(
      uint256 market_id,
      uint8 winning_outcome
   ) public OnlyAdmin{
    require(market_id < markets_length, "Market Does not exist");
   
    Market storage currentMarket=markets[market_id];
    require(currentMarket.deadline < block.timestamp,"Market has not expired yet");
    require(currentMarket.is_settled == false, "Market has already been settled");
    require(currentMarket.is_active == true, "Market is not active");
    require(winning_outcome < 2, "Invalid outcome index");
    for (uint256 i=0; i<2 ;i++){
        if(i==(winning_outcome)){
        currentMarket.winning_outcome=currentMarket.outcomes[i];
        } 
    }
    currentMarket.is_settled=true;
    currentMarket.is_active=false;
   }

    function toggle_market(
        uint256 market_id,
        uint8 category
    ) public OnlyAdmin{
        require(category<3,"Please Input correct Category for the markets");
        if(category==2){
            require((category==2 && market_id < markets_length),"Please Input correct market Id");
            Market storage currentMarket=markets[market_id];
            currentMarket.is_active=!currentMarket.is_active;
            //emit event
        }else if(category==1){
            require((category==1 && market_id < crypto_markets_length),"Please Input correct market Id for crypto markets");
             CryptoMarket storage currentMarket=crypto_markets[market_id];
            currentMarket.is_active=!currentMarket.is_active;
             //emit event
        }else{
            require((category==0 && market_id < sports_markets_length),"Please Input correct market Id for sports");
            SportsMarket storage currentMarket=sport_markets[market_id];
            currentMarket.is_active=!currentMarket.is_active;
             //emit event
        }
    }

    function get_user_total_claimable(
        address user
    ) public view returns (uint256){
        uint256 total=0; 
        for(uint256 i=0; i < markets_length; i++){
            Market storage currentMarket=markets[i];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            uint256 total_bets=num_bets[user][2][i];
            if(currentMarket.is_settled != false){
                for(uint256 k=0; k < total_bets; k++){
                    UserBet storage user_bet=user_bets[user][2][i][k];
                    if(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(user_bet.outcome.name)) 
                        && user_bet.position.has_claimed == false 
                        && user_bet.outcome.bought_shares > 0){
                        total += user_bet.position.amount * currentMarket.money_in_pool / user_bet.outcome.bought_shares; 
                    }
                } 
            }
        }

        for(uint256 i=0; i < sports_markets_length; i++){
            SportsMarket storage currentMarket=sport_markets[i];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            uint256 total_sports_bets=num_bets[user][2][i];
            if(currentMarket.is_settled != false){
               for(uint256 k=0; k < total_sports_bets; k++){
                    UserBet storage user_bet=user_bets[user][0][i][k];
                    if(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(user_bet.outcome.name)) 
                        && user_bet.position.has_claimed == false 
                        && user_bet.outcome.bought_shares > 0){
                        total += user_bet.position.amount * currentMarket.money_in_pool / user_bet.outcome.bought_shares; 
                    }
                } 
            }
        }

        for(uint256 i=0; i < crypto_markets_length; i++){
            CryptoMarket storage currentMarket=crypto_markets[i];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            uint256 total_crypto_bets=num_bets[user][2][i];
            if(currentMarket.is_settled != false){
                for(uint256 k=0; k < total_crypto_bets; k++){
                    UserBet storage user_bet=user_bets[user][1][i][k];
                    if(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(user_bet.outcome.name)) 
                        && user_bet.position.has_claimed == false 
                        && user_bet.outcome.bought_shares > 0){
                      total += user_bet.position.amount * currentMarket.money_in_pool / user_bet.outcome.bought_shares; 
                    }
                } 
            }
        }
        return total;
    }

    function buy_shares(
        uint256 market_id,
        uint8 token_to_mint,
        uint8 market_type
    ) public payable returns (bool){
        require(market_type < 3,"Please provide appropriate market Id");
        require(msg.value > 0,"Please provide some value to buy shares");
        uint256 amount=msg.value;
        if(market_type == 2){
            require(market_id < markets_length,"Market doesnt exist");
            Market storage currentMarket=markets[market_id];
            require(currentMarket.deadline > block.timestamp, "Market has expired, can't place a bet");
            require(currentMarket.is_active == true, "Market is not active");
            uint256 bought_shares=amount - (amount*PLATFORM_FEE/100);
           uint256 money_in_pool=currentMarket.money_in_pool + bought_shares;
            currentMarket.outcomes[token_to_mint].bought_shares+=bought_shares;
            currentMarket.money_in_pool=money_in_pool;
            num_bets[msg.sender][2][market_id] += 1;
            uint256 numOfBets=num_bets[msg.sender][2][market_id];
            UserBet memory currentUserBet = UserBet({
                    outcome:currentMarket.outcomes[token_to_mint],
                    position:UserPosition({
                        amount : bought_shares,
                        has_claimed : false
                    })
            });
            user_bets[msg.sender][2][market_id][numOfBets-1]=currentUserBet; 
        }else if(market_type==0){
            require(market_id < sports_markets_length,"Market doesnt exist");
            SportsMarket storage currentMarket=sport_markets[market_id];
            require(currentMarket.deadline > block.timestamp, "Market has expired, can't place a bet");
            require(currentMarket.is_active == true, "Market is not active");
            uint256 bought_shares=amount - (amount*PLATFORM_FEE/100);
            uint256 money_in_pool=currentMarket.money_in_pool + bought_shares;
            currentMarket.outcomes[token_to_mint].bought_shares+=bought_shares;
            currentMarket.money_in_pool=money_in_pool;
            num_bets[msg.sender][0][market_id] += 1;
            uint256 numOfBets=num_bets[msg.sender][0][market_id];
            UserBet memory currentUserBet = UserBet({
                    outcome:currentMarket.outcomes[token_to_mint],
                    position:UserPosition({
                        amount : bought_shares,
                        has_claimed : false
                    })
            });
            user_bets[msg.sender][0][market_id][numOfBets-1]=currentUserBet; 
        }else{
            require(market_id < crypto_markets_length,"Market doesnt exist");
            CryptoMarket storage currentMarket=crypto_markets[market_id];
            require(currentMarket.deadline > block.timestamp, "Crypto Market has expired, can't place a bet");
            require(currentMarket.is_active == true, "Crypto Market is not active");
            uint256 bought_shares=amount - (amount * PLATFORM_FEE / 100);
            uint256 money_in_pool=currentMarket.money_in_pool + bought_shares;
            currentMarket.outcomes[token_to_mint].bought_shares+=bought_shares;
            currentMarket.money_in_pool=money_in_pool;
            num_bets[msg.sender][1][market_id] += 1;
            uint256 numOfBets=num_bets[msg.sender][1][market_id];
            UserBet memory currentUserBet = UserBet({
                    outcome:currentMarket.outcomes[token_to_mint],
                    position:UserPosition({
                        amount : bought_shares,
                        has_claimed : false
                    })
            });
            user_bets[msg.sender][1][market_id][numOfBets-1]=currentUserBet; 
        }
        return true;
    }

    function get_treasury_wallet() public view OnlyAdmin returns(address){
        return treasuryWallet;
    }

    function claim_winnings(
        uint256 market_id,
        uint8 market_type,
        uint8 bet_num
    ) public {
         require(market_type < 3,"Please provide appropriate market Id");
        if(market_type == 2){
            require(market_id < markets_length,"Market doesnt exist");
            Market storage currentMarket=markets[market_id];
            require(currentMarket.deadline < block.timestamp, "Market has not expired yet, can't claim winnings");
            require(currentMarket.is_active == false, "Market is active right now");
            UserBet storage currentUserBet=user_bets[msg.sender][2][market_id][bet_num];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            require(currentUserBet.position.amount > 0, "User has no active positions in this market");
            require(currentUserBet.position.has_claimed == false, "User has already claimed their winnings");
            require(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(currentUserBet.outcome.name)),"User did not win");
            require(currentUserBet.outcome.bought_shares > 0, "No amount of bought shares");
            uint256 winnings= currentUserBet.position.amount * currentMarket.money_in_pool / currentUserBet.outcome.bought_shares;
            currentUserBet.position.has_claimed=true;
            (bool success, ) = msg.sender.call{value: winnings}("");
            require(success, "Transfer failed");
            
            //Emit event
        }else if(market_type==0){
            require(market_id < sports_markets_length,"Market doesnt exist");
            SportsMarket storage currentMarket=sport_markets[market_id];
            require(currentMarket.deadline < block.timestamp,"Market has not expired yet, can't claim winnings");
            require(currentMarket.is_active == false, "Market is active right now");
            UserBet storage currentUserBet=user_bets[msg.sender][0][market_id][bet_num];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            require(currentUserBet.position.amount > 0, "User has no active positions in this market");
            require(currentUserBet.position.has_claimed == false, "User has already claimed their winnings");
            require(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(currentUserBet.outcome.name)),"User did not win");
            require(currentUserBet.outcome.bought_shares > 0, "No amount of bought shares");
            uint256 winnings= currentUserBet.position.amount * currentMarket.money_in_pool / currentUserBet.outcome.bought_shares;
            currentUserBet.position.has_claimed=true;
           (bool success, ) = msg.sender.call{value: winnings}("");
            require(success, "Transfer failed");
            
        }else{
            require(market_id < crypto_markets_length,"Market doesn't exist");
            CryptoMarket storage currentMarket=crypto_markets[market_id];
            require(currentMarket.deadline < block.timestamp,"Market has not expired yet, can't claim winnings");
            require(currentMarket.is_active == false, "Market is active right now");
            UserBet storage currentUserBet=user_bets[msg.sender][1][market_id][bet_num];
            Outcome memory winningOutcome=currentMarket.winning_outcome;
            require(currentUserBet.position.amount > 0, "User has no active positions in this market");
            require(currentUserBet.position.has_claimed == false, "User has already claimed their winnings");
            require(keccak256(abi.encodePacked(winningOutcome.name)) == keccak256(abi.encodePacked(currentUserBet.outcome.name)),"User did not win");
            require(currentUserBet.outcome.bought_shares > 0, "No amount of bought shares");
            uint256 winnings= currentUserBet.position.amount * currentMarket.money_in_pool / currentUserBet.outcome.bought_shares;
            currentUserBet.position.has_claimed=true;
            (bool success, ) = msg.sender.call{value: winnings}("");
            require(success, "Transfer failed");
        }    
    }
    
    function set_treasury_wallet(
        address payable wallet
    ) public OnlyAdmin{
        treasuryWallet=wallet;
    }

}
