pragma solidity ^0.4.18;
		pragma experimental ABIEncoderV2;
		/// @title ���̲���
		/// @author ֣����
		/// @notice ������������Լ�еĺ������������ϵĻ������������ʼ�����̣���һ�����ӵ�
		contract MineSweeper {
		  uint8 constant N = 4;//�������̴�С
		  uint8 constant M = 5;//�����׵�����
		  uint private randNonce = 0;//�����������
		  int[N+2][N+2] private a;//���̵Ĳ������
		  bytes[N+2][N+2] Map;//���û�չʾ���������
		  bytes Unexp = "#";//δ̽���ĸ���
		  bool Initialize = false;//�Ƿ��ʼ��
		  int[9]  DireX = [-1,0,0,1,-1,1,1,-1,-1];
		  int[9]  DireY = [-1,1,-1,0,0,1,-1,1,-1];//��������
			///@notice ����һ������l~r֮��������
		  function RandomInt(uint8 l,uint8 r)private returns(uint8){
		    ++randNonce;
		    return uint8(keccak256(now, msg.sender, randNonce)) % (r - l + 1) + l;
		  }
			///@notice �������������Χ���׵�����
		  function MineCount(uint8 x,uint8 y)private returns(int){
		      if(a[x][y]==-1)return -1;//������������ף����ü���
		      int ans=0;
		      uint8 i;
		      for(i=1;i<=8;i++)
		        if(a[uint(int(x)+DireX[i])][uint(int(y)+DireY[i])]==-1)
		            ans++;
		    return ans;
		  }
			///@notice ��ʼ������
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
		        while(a[x][y]==-1){//ȷ����������ظ�������
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
		      Initialize = true;//�ѳ�ʼ��
		  }
			///@notice ���������ַ���
			///@author �˶κ�����Դ�ڡ�����������DAPP���š�(����ʤ��)
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
			///@notice �����ǰ������ҵ�Map
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
			///@notice �ж������ַ����Ƿ����
		  function check(string x,string y)private view returns(bool){
		      return (keccak256(x)!=keccak256(y));
		  }
			///@notice ��intת��Ϊbytes
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
			///@notice ʹ�õݹ�򿪸���
			///@param x,y  ����
			///@param stp ��ǰ��������
			///@param tot ���β����ܹ���tot������
			///@dev ��ʹstp==1,Ҳ���ܹ�ֻ��һ�����ӣ���Ϊ��չ��3-7������һ���Ϸ�
		  function OpenIt(uint8 x,uint8 y,uint stp,uint8 tot) private returns (string){
		      if(x<0||y<0||x>=N||y>=N||tot>=10||
					check(string(Map[x][y]),string(Unexp))==true||
					a[x+1][y+1]==-1)
						return;
		      Map[x][y]=Count(a[x+1][y+1]);
		      if(a[x+1][y+1]==0){//������������Χ���ף������������������и���
		          for(uint8 i=1;i<=8;i++)
		            OpenIt(uint8(x+uint8(DireX[i])),uint8(y+uint8(DireY[i])),stp,++tot);
		      }else if(stp==1){//�����ǰΪ��һ�������������Χ3-7������
		          uint8 t = RandomInt(3,7);
		          for(i=1;i<=t;i++){
		            uint8 tmp=RandomInt(1,8);
		            OpenIt(uint8(x+uint8(DireX[tmp])),uint8(y+uint8(DireY[tmp])),stp,++tot);
		          }
		      }
		      return "done";
		  }
		  uint stp=0;
			///@notice �������Ϸ���
		  function IsValid(uint8 x,uint8 y)private view returns(uint8){
		      if(a[x][y]==-1&&stp==0)return 0;//��һ����������
		      if(x<=0||y<=0||x>N||y>N)return 1;//���뷶Χ����
		      if(check(string(Map[x-1][y-1]),string(Unexp))) return 2;//����һ���򿪹��ĸ���
		      return 3;//����
		  }
			///@notice ����Ƿ��ʤ
		  function IsWin()private view returns (bool){
		      uint8 undid=0;
		      for(uint8 i=0;i<N;i++)
		        for(uint j=0;j<N;j++)
		            if(check(string(Map[i][j]),string(Unexp))==false)
		                ++undid;
		      return (undid==M);
		  }
			///@notice ������ҵĲ���ѡ�
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
