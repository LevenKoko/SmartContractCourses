pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;
import "./MineSweeper.sol";
/// @title ��һ���
/// @author ֣����
/// @notice ��Ҫ��������һ���
contract Play is MineSweeper{// �̳���MineSweeper
    address[2] players;//��¼������ҵĵ�ַ
    uint Num;//��¼�Ѽ����������
    mapping(address => uint) Score;//��¼��ҳɼ�
    uint stake;//��¼��ע
    bool going=true;//��¼��Ϸ�Ƿ���������
    ///@notice ����޸��������жϵ�ǰ����Ƿ���Լ���
    modifier isJoinable() {
        require(players[0] == address(0) || players[1] == address(0),
                "The room is full."
        );//��������
        require((players[0] != address(0) && msg.value == stake) || (players[0] == address(0)),
                "You must pay the EXCAT stake to play the game."
        );//stake��������һ����Ҳ����
        _;
    }
    ///@notice �����жϵ�ǰ����������Ƿ�����Ϸǰ�����������
    modifier isPlayer(){
        require(msg.sender==players[0]||msg.sender==players[1],
            "You are not playing in the game!"
        );
        _;
    }
    ///@notice �����ж���Ϸ�Ƿ�δ����
    modifier NotEnd() {
      require(going==true,
        "Game is over already!"
        );
      _;
    }
    ///@notice �����ж��Ƿ��ʼ������
    modifier HaveInit() {
        require(Initialize==true,"You have not INITIALIZED!");
        _;
    }
    ///@notice ��ʾ��ǰ������ҵĵ�ַ
    function RealTimePlayers()public view returns(address,address){
        return (players[0],players[1]);
    }
    ///@notice �õ�ǰ�˻���Ҽ�����Ϸ
    function JoinTheGame() public payable isJoinable{
        require(msg.value >= 1 finney,"The stakes are too LOW!!!");
        //Ҫ��stake>=1finnye
        players[Num] = msg.sender;
        ++Num;
        if(Num==1){stake = msg.value;Time = now;}//���1ӵ���趨stake��Ȩ��
    }
    ///@notice �����2��ʱ��δ������Ϸ�����һ���������˿�
    function WithdrawMoney() public isPlayer {
        require(now - Time > 30 seconds, "Please wait at lease 30 seconds to get your ether back!");
        players[0].transfer(stake);
    }
    ///@notice ��ʾʵʱ��ͼ
    function RealTimeMap() public view isPlayer returns(string[N] memory){
        return Output_Now();
    }
    ///@notice �ж������ַ����Ƿ����
    function Equal(string x,string y)private view returns(bool){
        return (keccak256(x)==keccak256(y));
    }
    ///@notice ȡ���ֵ
    function Max(uint x,uint y)private returns(uint){
        if(x>=y)return x;
        return y;
    }
    ///@notice ȡ��Сֵ
   function Min(uint x,uint y)private returns(uint){
        if(x>=y)return y;
        return x;
    }
    ///@notice ����֮��Ϸֽ���
    function Lose(address x) private {
        going=false;
        address y;
        if(x==players[0])y=players[1];else y=players[0];
        if(x<=2){x.transfer(stake-0.5 finney);y.transfer(stake+0.5 finney);return;}
        x.transfer(((Score[x]*2*stake)/(Score[x]+Score[y])));
        y.transfer(((Score[y]*2*stake)/(Score[x]+Score[y])));
    }
    ///@notice Ӯ��֮��Ϸֽ���
    function Win(address x) private {
        going=false;
        address y;
        if(x==players[0])y=players[1];else y=players[0];
        x.transfer(Min(((Score[x]*2*stake)/(Score[x]+Score[y])) + stake,stake*2));
        y.transfer(Max(((Score[y]*2*stake)/(Score[x]+Score[y])) - stake,0));
    }
    ///@notice ��(x,y)�ĸ���
    function OpenAt(uint8 x,uint8 y) public isPlayer NotEnd HaveInit{
        string memory res = Open(x,y);//�ж��Ƿ�Ϸ�
        if(Equal(res,"You Lose!")==true)  {Lose(msg.sender);return;}
        if(Equal(res,"Win!")==true)       {Win(msg.sender);return;}
        if(Equal(res,"Succeed operation!")==true){++Score[msg.sender];}
    }
}
