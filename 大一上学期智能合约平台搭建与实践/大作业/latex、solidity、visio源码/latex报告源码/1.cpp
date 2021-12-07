#include<bits/stdc++.h>
using namespace std;
const int N = 5,  //9*9 Map
          m = 10; //10 Mines
int a[N+5][N+5];
char Map[N+5][N+5];
//@author:Leven
//#function
default_random_engine e;
inline int RandomInt(int l,int r){
  uniform_int_distribution<int> u(l,r);
  return u(e);
}
const int Dire_X[] = {0,0,0,1,-1,1,1,-1,-1} ,
          Dire_Y[] = {0,1,-1,0,0,1,-1,1,-1} ;
inline int MineCount(int x,int y){
  if(a[x][y]==-1)return -1;
  int ans=0;
  for(int i=1;i<=8;i++)
    ans+=(a[x+Dire_X[i]][y+Dire_Y[i]]==-1);
  return ans;
}
inline void Output(){
  for(int i=1;i<=N;i++,puts(""))
    for(int j=1;j<=N;j++)
      cout<<a[i][j]<<'\t';
}
inline void Init(){
  //Mine Generation
  memset(a,0,sizeof(a));
  for(int i=1;i<=m;i++){
    int x = RandomInt(1,N), y = RandomInt(1,N);
    while(a[x][y])x = RandomInt(1,N), y = RandomInt(1,N);
    a[x][y] = -1;
  }
  //Get Map
  for(int i=1;i<=N;i++)
    for(int j=1;j<=N;j++)
      a[i][j] = MineCount(i,j),
      Map[i][j]='#';
  // Output();
}
inline void Output_Now(){
  for(int i=1;i<=N;i++,puts(""))
    for(int j=1;j<=N;j++)
      cout<<Map[i][j];
}
inline char Count(int x,int y){
  if(a[x][y]==-1)return '@';
  return a[x][y]+48;
}
inline void OpenIt(int x,int y,int stp,int tot){
  if(x<=0||y<=0||x>N||y>N||Map[x][y]!='#'||a[x][y]==-1)return;
  if(tot>=10)return;
  Map[x][y]=Count(x,y);
  if(a[x][y]==0){
    for(int i=1;i<=8;i++)
      OpenIt(x+Dire_X[i],y+Dire_Y[i],stp,++tot);
  }else if(stp==1){
    int cnt = RandomInt(3,7);
    for(int i=1;i<=cnt;i++){
      int t = RandomInt(1,8);
      OpenIt(x+Dire_X[t],y+Dire_Y[t],stp,++tot);
    }
  }
}
inline bool check(){
  int ans=0;
  for(int i=1;i<=N;i++)
    for(int j=1;j<=N;j++)
      ans+=(Map[i][j]=='#');
  return ans==10;
}
inline void Solve(){
  puts("input (x,y)");
  int x,y,stp=0;
  Output();
  while(cin>>x>>y){
    while(stp==0&&a[x][y]==-1)Init();//直接踩雷，重新生成地图；
    if(a[x][y]==-1){puts("You Lose");break;}
    OpenIt(x,y,++stp,0);
    if(check()){puts("You Win");break;}
    Output_Now();
  }
}
int main(){
  e.seed(time(0));
  Init();//Get MineMap
  Solve();//Begin & Have fun.
  return 0;
}
