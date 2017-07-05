#pragma once
#include <fstream>

using namespace std;

struct Edge {
    int x, y;
    int weight;
};

class MST {
private:
    int count;
    int vNum, eNum;
    int *p;
    Edge *edge;

public:
    MST() : vNum(0), eNum(0), count(0) {
        this->p = nullptr;
        this->edge = nullptr;
    };
    MST(int, int);
    ~MST();

    void addEdge(int, int, int);
    void cal();
    
    friend ofstream& operator <<(ofstream&, MST&);
};

