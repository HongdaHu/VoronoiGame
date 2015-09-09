//
//  GamePoint.cpp
//  VoronoiGame
//
//  Created by Robin on 4/12/15.
//  Copyright (c) 2015 Hongda. All rights reserved.
//

#include "GamePoint.h"

using namespace std;

const float LENGTH = 320.0;
const float HEIGHT = 536.0;

class PolyPoint{
public:
    float x,y;
    PolyPoint(float ix,float iy){
        x=ix;
        y=iy;
    }
};

class PolyPointList{
public:
    map<std::pair<float,float>, int> p_id;
    map<int, PolyPoint*> id_p;
    
    ~PolyPointList(){
        for(auto iter=id_p.begin();iter!=id_p.end();iter++){
            delete iter->second;
        }
    }
    
    int add_list(float x, float y){
        if(p_id.find(make_pair(x,y))!=p_id.end()) return p_id[make_pair(x,y)];
        int id=(int)p_id.size();
        p_id[make_pair(x, y)]=id;
        id_p[id]=new PolyPoint(x,y);
        return id;
    }

    PolyPoint* get_point(int id){
        if(id_p.find(id)==id_p.end()) {
            cout<<id<<"ID in PolyPointList out of range!"<<endl;
            return (PolyPoint *)NULL;
        }
        return id_p[id];
    }
    
    int get_id(float x,float y){
        if(p_id.find(make_pair(x,y))==p_id.end()) return -1;
        return p_id[make_pair(x,y)];
    }

};

class Border{
public:
    set<float, greater<float> > leftB;
    set<float> rightB;
    set<float> topB;
    set<float, greater<float> > bottomB;
    PolyPointList borderpointslist;
    map<int,int> nextpointid;
    
    Border(){
        leftB.insert(0.0);
        leftB.insert(HEIGHT);
        rightB.insert(0.0);
        rightB.insert(HEIGHT);
        topB.insert(0.0);
        topB.insert(LENGTH);
        bottomB.insert(0.0);
        bottomB.insert(LENGTH);
    }
    
    void cutBorder(float x,float y){
        if(x==0&&y!=0) leftB.insert(y);
        if(x==LENGTH&&y!=0) rightB.insert(y);
        if(x!=0&&y==0) topB.insert(x);
        if(x!=0&&y==HEIGHT) bottomB.insert(x);
    }
    
    //continue the clock-wise linked list.
    void init_bplist(){
        //left:
        float pre=-1;
        for(auto iter = leftB.begin();iter!=leftB.end();iter++){
            if(pre>=0){
                nextpointid[borderpointslist.add_list(0,pre)] = borderpointslist.add_list(0, *iter);
            }
            pre = *iter;
        }
        pre = -1;
        for(auto iter = topB.begin();iter!=topB.end();iter++){
            if(pre>=0){
                nextpointid[borderpointslist.add_list(pre, 0)] = borderpointslist.add_list(*iter, 0);
            }
            pre = *iter;
        }
        pre = -1;
        for(auto iter = rightB.begin();iter!=rightB.end();iter++){
            if(pre>=0){
                nextpointid[borderpointslist.add_list(LENGTH, pre)] = borderpointslist.add_list(LENGTH,*iter);
            }
            pre = *iter;
        }
        pre = -1;
        for(auto iter = bottomB.begin();iter!=bottomB.end();iter++){
            if(pre>=0){
                nextpointid[borderpointslist.add_list(pre, HEIGHT)] = borderpointslist.add_list(*iter,HEIGHT);
            }
            pre = *iter;
        }
    }

    PolyPoint * get_nextBpoint(float x, float y){
        try {
            int preid = borderpointslist.get_id(x,y);
            return borderpointslist.get_point(nextpointid[preid]);
        } catch (exception) {
            cout<<"can not get the next point!";
            return (PolyPoint *)nullptr;
        }
    }
};

class GamePoint{
public:
    float x,y;
    int id;
    int player;
    map<int,int> edges;
    PolyPointList selfpplist;
    Border *commonBorder;
    vector<int> loopVertexID;
    
    GamePoint(int iid,int iplayer,float ix,float iy,Border* iBorder){
        id=iid;
        player=iplayer;
        x=ix;
        y=iy;
        commonBorder = iBorder;
    }
    
    void add_edge(PolyPoint p1, PolyPoint p2, int idnum){
        if(p1.x==p2.x&&p1.y==p2.y) return; // the edge is a point, return.
        if(id!=idnum) return; // wrong id num, return.
        //get vector e
        float ex = p2.x - p1.x;
        float ey = p2.y - p1.y;
        //get vector v
        float vx = this->x - p1.x;
        float vy = this->y - p1.y;
        //get cross product of e&v => sin(a)
        float cross = (ex*vy)-(ey*vx);
        if(cross>0){//sin(a)>0, on the left
            edges[selfpplist.add_list(p1.x,p1.y)]=selfpplist.add_list(p2.x,p2.y);
        }else if(cross<0){// on the right
            edges[selfpplist.add_list(p2.x,p2.y)]=selfpplist.add_list(p1.x,p1.y);
        }
        return;
    }
    
    bool genEdgeLoop(){
        try {
            int startid,edgeid;
            if (edges.size()==0){// no edges, start with border.
                loopVertexID.push_back(selfpplist.add_list(0, 0));
                startid = loopVertexID[0];
            }else{
                startid = edges.begin()->first;
                loopVertexID.push_back(startid);
            }
            edgeid = startid;
            
            while (true){
                if(edges.find(edgeid)!=edges.end()){//inside the box
                    if (edges[edgeid]==startid) return true;
                    edgeid = edges[edgeid];
                    loopVertexID.push_back(edgeid);
                }else{                              //bound of the box
                    PolyPoint* point = selfpplist.get_point(edgeid);
                    PolyPoint *temp = commonBorder->get_nextBpoint(point->x,point->y);
                    if (temp!=nullptr) {// found the edge in bound
                        edgeid = selfpplist.add_list(temp->x, temp->y);
                        if (edgeid==startid) return true;
                        loopVertexID.push_back(edgeid);
                    }else{
                        cout<<"can't find in border!!!";
                        return false;
                    }
                }
            }
            return true;
        } catch (exception) {
            return false;
        }
    }
    
    int get_edges_num(){
        return (int)loopVertexID.size();
    }
    
    void get_ref_xy(int index,float &x,float &y){
        if (index>=loopVertexID.size()) {
            x=-1;
            y=-1;
            return;
        }
        x = selfpplist.get_point(loopVertexID[index])->x;
        y = selfpplist.get_point(loopVertexID[index])->y;
    }
    
    float get_area(){
        if(loopVertexID.size()<3) return 0;
        float res=0;
        float ex,ey;
        get_ref_xy(0,ex,ey);
        float ax,ay,bx,by;
        for (int i=2; i<loopVertexID.size(); i++) {
            get_ref_xy(i, ax, ay);
            get_ref_xy(i-1, bx, by);
            res += ( (bx-ex) * (ay-ey) - (by-ey) * (ax-ex) )/2;
        }
        return res;
    }
};


