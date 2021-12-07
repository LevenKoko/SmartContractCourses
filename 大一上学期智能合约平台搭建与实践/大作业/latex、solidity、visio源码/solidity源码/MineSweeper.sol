pragma solidity ^0.4.18;
		pragma experimental ABIEncoderV2;
		/// @title 棋盘操作
		/// @author 郑力文
		/// @notice 你可以用这个合约中的函数进行棋盘上的基本操作，如初始化棋盘，打开一个格子等
		contract MineSweeper {
		  uint8 constant N = 4;//设置棋盘大小
		  uint8 constant M = 5;//设置雷的数量
		  uint private randNonce = 0;//随机数生成用
		  int[N+2][N+2] private a;//棋盘的布局情况
		  bytes[N+2][N+2] Map;//对用户展示的棋盘情况
		  bytes Unexp = "#";//未探索的格子
		  bool Initialize = false;//是否初始化
		  int[9]  DireX = [-1,0,0,1,-1,1,1,-1,-1];
		  int[9]  DireY = [-1,1,-1,0,0,1,-1,1,-1];//方向向量
			///@notice 生成一个介于l~r之间的随机数
		  function RandomInt(uint8 l,uint8 r)private returns(uint8){
		    ++randNonce;
		    return uint8(keccak256(now, msg.sender, randNonce)) % (r - l + 1) + l;
		  }
			///@notice 计算这个格子周围的雷的数量
		  function MineCount(uint8 x,uint8 y)private returns(int){
		      if(a[x][y]==-1)return -1;//若这个格子是雷，不用计算
		      int ans=0;
		      uint8 i;
		      for(i=1;i<=8;i++)
		        if(a[uint(int(x)+DireX[i])][uint(int(y)+DireY[i])]==-1)
		            ans++;
		    return ans;
		  }
			///@notice 初始化棋盘
		  function Init()public {
		      uint8 i;
		      uint8 j;
		      uint8 x;
		      uint8 y;
		      for(i=1;i<=N;i++)
		        for(j=1;j<=N;j++)
		            a[i][j]=0;
		      for(i=1;i<=M;i++){
		        x=RandomInt(1,N);
		        y=RandomInt(1,N);
		        while(a[x][y]==-1){//确保不会产生重复的坐标
		            x=RandomInt(1,N);
		            y=RandomInt(1,N);
		        }
		        a[x][y]=-1;
		      }
		      for(i=1;i<=N;i++)
		        for(j=1;j<=N;j++){
		            a[i][j]=MineCount(i,j);
		            Map[i-1][j-1]="#";
		        }
		      Initialize = true;//已初始化
		  }
			///@notice 连接两个字符串
			///@author 此段函数来源于《区块链开发DAPP入门》(李万胜著)
		  function strConcat(string memory _a, string memory _b) private returns (string memory){
		    bytes memory _ba = bytes(_a);
		    bytes memory _bb = bytes(_b);
		    string memory ret = new string(_ba.length + _bb.length);
		    bytes memory bret = bytes(ret);
		    uint k = 0;
		    uint i;
		    for (i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
		    for (i = 0; i < _bb.length; i++)bret[k++] = _bb[i];
		    return string(ret);
		  }
			///@notice 输出当前面向玩家的Map
		  function Output_Now() internal view returns (string[N] memory){
		      uint8 i;
		      uint8 j;
		      string[N] memory s;
		      for(i=0;i<N;i++){
		        for(j=0;j<N;j++)
		        s[i]=strConcat(s[i],string(Map[i][j]));
		      }
		      return s;
		  }
			///@notice 判断两个字符串是否不相等
		  function check(string x,string y)private view returns(bool){
		      return (keccak256(x)!=keccak256(y));
		  }
			///@notice 将int转换为bytes
		  function Count(int x)private returns(bytes){
		      if(x==0)return "0";
		      if(x==1)return "1";
		      if(x==2)return "2";
		      if(x==3)return "3";
		      if(x==4)return "4";
		      if(x==5)return "5";
		      if(x==6)return "6";
		      if(x==7)return "7";
		      if(x==8)return "8";
		  }
			///@notice 使用递归打开格子
			///@param x,y  坐标
			///@param stp 当前操作步数
			///@param tot 本次操作总共打开tot个格子
			///@dev 即使stp==1,也有总共只打开一个格子，因为扩展的3-7个方向不一定合法
		  function OpenIt(uint8 x,uint8 y,uint stp,uint8 tot) private returns (string){
		      if(x<0||y<0||x>=N||y>=N||tot>=10||
					check(string(Map[x][y]),string(Unexp))==true||
					a[x+1][y+1]==-1)
						return;
		      Map[x][y]=Count(a[x+1][y+1]);
		      if(a[x+1][y+1]==0){//如果这个格子周围无雷，则打开这个格子四周所有格子
		          for(uint8 i=1;i<=8;i++)
		            OpenIt(uint8(x+uint8(DireX[i])),uint8(y+uint8(DireY[i])),stp,++tot);
		      }else if(stp==1){//如果当前为第一步，则随机打开周围3-7个格子
		          uint8 t = RandomInt(3,7);
		          for(i=1;i<=t;i++){
		            uint8 tmp=RandomInt(1,8);
		            OpenIt(uint8(x+uint8(DireX[tmp])),uint8(y+uint8(DireY[tmp])),stp,++tot);
		          }
		      }
		      return "done";
		  }
		  uint stp=0;
			///@notice 检查输入合法性
		  function IsValid(uint8 x,uint8 y)private view returns(uint8){
		      if(a[x][y]==-1&&stp==0)return 0;//第一步就遇到雷
		      if(x<=0||y<=0||x>N||y>N)return 1;//输入范围错误
		      if(check(string(Map[x-1][y-1]),string(Unexp))) return 2;//打开了一个打开过的格子
		      return 3;//正常
		  }
			///@notice 检查是否获胜
		  function IsWin()private view returns (bool){
		      uint8 undid=0;
		      for(uint8 i=0;i<N;i++)
		        for(uint j=0;j<N;j++)
		            if(check(string(Map[i][j]),string(Unexp))==false)
		                ++undid;
		      return (undid==M);
		  }
			///@notice 面向玩家的操作选项卡
		  function Open(uint8 x,uint8 y)internal returns (string){
		      uint8 ErrId = IsValid(x,y);
		      if(ErrId==0) revert("You meet a Mine in your first step,try again!");
		      if(ErrId==1) revert("Wrong Range,try again!");
		      if(ErrId==2) revert("Meet a used place,try again");
		      ++stp;
		      if(a[x][y]==-1){return "You Lose!";}
		      --x;--y;
		      OpenIt(x,y,stp,1);
		      if(IsWin()){return "Win!";}
		      return "Succeed operation!";
		  }
		}
