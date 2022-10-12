//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

contract SportsBet{
    //to mark the selections of players
    enum GameResult{Scorless,Team1,Team2, NotStarted }
    //fundamental properties match object
    struct Game{
        string gameId;
        string team1;
        string team2;
        uint256 gameStartDate;
        uint256 gameEndDate;
        GameResult result;
    }
    //properties of the player object
    struct Player{
        address payable playerId;
        GameResult selection;
        uint256 amount;
        bool win;
        uint256 resultAmount;
    }
    //variables
    address public immutable owner;
    uint256 public balance;
    uint public transactionFeePercentage;
    Game[] public games;
    //Key: gameId, Value: PlayerArray; collects the game and players bet on it
    mapping(string=>Player[])public Bets;
    //events
    event GameAdded(string gameId, address admin);
    event GameEnded(string gameId, GameResult result);
    event TransactionsCompleted(string gameId, address player, uint256 amount);
    event PlayerJoinBet(string gameId, address player, uint256 amount, GameResult choice);

    constructor(){
        owner=msg.sender;
        transactionFeePercentage=10;
    } 
    function GetOwner()public view returns (address){
        return owner;
    }
    //get the recorded matches
    function GetMatches() public view returns(Game[] memory){
        return games;
    }
    //this function saves the match information
    function AddGame(string memory _gameId, string memory _team1, string memory _team2, uint256 _gameStartDate, uint256 _gameEndDate) public returns(bool){
        require(msg.sender==owner, "Only admin add game");
        require(_gameStartDate > block.timestamp, "game already ended");
        games.push(Game({gameId:_gameId, team1:_team1,team2:_team2,gameStartDate:_gameStartDate,gameEndDate:_gameEndDate,result:GameResult.NotStarted}));
        emit GameAdded(_gameId, msg.sender);
        return true;
    }
    //this function sets the game result and send the money to the winners
    function EndGame(string memory _gameId, GameResult _result) public returns(bool){
        require(msg.sender==owner, "Only admin end bet");
        (bool found, uint256 location)=FindGame(_gameId);
        require(found, "Game not found");

        require(games[location].gameEndDate > block.timestamp, "game has not ended");
        games[location].result=_result;
        emit GameEnded(_gameId, _result);

        //determine total ether
        uint256 loosersAmount;
        uint256 winnersAmount;
        for(uint256 i=0;i<Bets[_gameId].length;i++){
            if(Bets[_gameId][i].selection==_result)winnersAmount+=Bets[_gameId][i].amount;
            else loosersAmount+=Bets[_gameId][i].amount;
        }
        //decrease transaction fee
        loosersAmount=loosersAmount-(loosersAmount*transactionFeePercentage)/100;
        //calculation part, after decreasing the expense amount, 
        //remaining of losers amount will be shared according to the percentage of the players on the total winners
         for(uint256 i=0;i<Bets[_gameId].length;i++){
             
            if(Bets[_gameId][i].selection==_result){

                uint256 totalPayback= Bets[_gameId][i].amount;
                uint256 proportion=(100*totalPayback)/winnersAmount;
                totalPayback+=(proportion/100)*loosersAmount;
                address payable playerAddress=Bets[_gameId][i].playerId;
                Bets[_gameId][i].resultAmount=totalPayback;
                Bets[_gameId][i].win=true;
                withdraw(totalPayback,playerAddress);
                emit TransactionsCompleted(_gameId, playerAddress, totalPayback);
            }
            else{
                Bets[_gameId][i].win=false;
            }
            
        }
        
        return true;
    }
    //sends ether to the winners
    function withdraw(uint256 amount, address payable destination)public{
        require(msg.sender==owner,"Only owner can withdraw");
        require(amount<=balance,"Insufficient funds");
        destination.transfer(amount);
        balance -=amount;
    }
    //this function takes player info and adds them to the bet
    function JoinBet(string memory _gameId, GameResult _gameResult, uint256 _amount, address payable _playerId)public payable returns(bool){
        (bool found, uint256 location)=FindGame(_gameId);
        if(found){
            require(games[location].gameStartDate > block.timestamp, "game already ended");
            balance+=_amount;
            Game memory game=games[location];
            Bets[game.gameId].push(Player({amount:_amount,playerId:_playerId,selection:_gameResult,resultAmount:0, win:false}));
            emit PlayerJoinBet(_gameId, msg.sender, _amount, _gameResult);
            return true;
        }
        else{
            return false;
        }
    }
    //searches and returns the result of search and indis of the game
    function FindGame(string memory _gameId) private view returns(bool, uint256){
        uint256 location;
        bool found=false;
        for(uint256 i=0;i<games.length;i++){
            if(stringsEquals(games[i].gameId,_gameId)){
                location=i;
                found=true;
                break;
            }
        }
        return (found, location);

    }
    //checks the two strings equality, 
    function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        uint256 l1 = b1.length;
        if (l1 != b2.length) return false;
        for (uint256 i=0; i<l1; i++) {
            if (b1[i] != b2[i]) return false;
        }
        return true;
    }
}
