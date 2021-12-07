pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;
import "./MineSweeper.sol";
/// @title 玩家互动
/// @author 郑力文
/// @notice 主要用于与玩家互动
contract Play is MineSweeper{// 继承自MineSweeper
    address[2] players;//记录两个玩家的地址
    uint Num;//记录已加入玩家数量
    mapping(address => uint) Score;//记录玩家成绩
    uint stake;//记录赌注
    bool going=true;//记录游戏是否正常进行
    ///@notice 这个修改器用于判断当前玩家是否可以加入
    modifier isJoinable() {
        require(players[0] == address(0) || players[1] == address(0),
                "The room is full."
        );//房间已满
        require((players[0] != address(0) && msg.value == stake) || (players[0] == address(0)),
                "You must pay the EXCAT stake to play the game."
        );//stake不足或与第一个玩家不相等
        _;
    }
    ///@notice 用于判断当前操作的玩家是否是游戏前加入的两个人
    modifier isPlayer(){
        require(msg.sender==players[0]||msg.sender==players[1],
            "You are not playing in the game!"
        );
        _;
    }
    ///@notice 用于判断游戏是否未结束
    modifier NotEnd() {
      require(going==true,
        "Game is over already!"
        );
      _;
    }
    ///@notice 用于判断是否初始化棋盘
    modifier HaveInit() {
        require(Initialize==true,"You have not INITIALIZED!");
        _;
    }
    ///@notice 显示当前两个玩家的地址
    function RealTimePlayers()public view returns(address,address){
        return (players[0],players[1]);
    }
    ///@notice 让当前账户玩家加入游戏
    function JoinTheGame() public payable isJoinable{
        require(msg.value >= 1 finney,"The stakes are too LOW!!!");
        //要求stake>=1finnye
        players[Num] = msg.sender;
        ++Num;
        if(Num==1){stake = msg.value;Time = now;}//玩家1拥有设定stake的权限
    }
    ///@notice 若玩家2长时间未加入游戏，玩家一可以申请退款
    function WithdrawMoney() public isPlayer {
        require(now - Time > 30 seconds, "Please wait at lease 30 seconds to get your ether back!");
        players[0].transfer(stake);
    }
    ///@notice 显示实时地图
    function RealTimeMap() public view isPlayer returns(string[N] memory){
        return Output_Now();
    }
    ///@notice 判断两个字符串是否相等
    function Equal(string x,string y)private view returns(bool){
        return (keccak256(x)==keccak256(y));
    }
    ///@notice 取最大值
    function Max(uint x,uint y)private returns(uint){
        if(x>=y)return x;
        return y;
    }
    ///@notice 取最小值
   function Min(uint x,uint y)private returns(uint){
        if(x>=y)return y;
        return x;
    }
    ///@notice 输了之后瓜分奖金
    function Lose(address x) private {
        going=false;
        address y;
        if(x==players[0])y=players[1];else y=players[0];
        if(x<=2){x.transfer(stake-0.5 finney);y.transfer(stake+0.5 finney);return;}
        x.transfer(((Score[x]*2*stake)/(Score[x]+Score[y])));
        y.transfer(((Score[y]*2*stake)/(Score[x]+Score[y])));
    }
    ///@notice 赢了之后瓜分奖金
    function Win(address x) private {
        going=false;
        address y;
        if(x==players[0])y=players[1];else y=players[0];
        x.transfer(Min(((Score[x]*2*stake)/(Score[x]+Score[y])) + stake,stake*2));
        y.transfer(Max(((Score[y]*2*stake)/(Score[x]+Score[y])) - stake,0));
    }
    ///@notice 打开(x,y)的格子
    function OpenAt(uint8 x,uint8 y) public isPlayer NotEnd HaveInit{
        string memory res = Open(x,y);//判断是否合法
        if(Equal(res,"You Lose!")==true)  {Lose(msg.sender);return;}
        if(Equal(res,"Win!")==true)       {Win(msg.sender);return;}
        if(Equal(res,"Succeed operation!")==true){++Score[msg.sender];}
    }
}
