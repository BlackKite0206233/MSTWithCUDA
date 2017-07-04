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
    int *v, *p;
    Edge *e;

public:
    MST() : vNum(0), eNum(0), count(0) {
        this->v = this->p = nullptr;
        this->e = nullptr;
    };
    MST(int, int);
    ~MST();

    void addEdge(int, int, int);
    void cal();
    
    friend ofstream& operator <<(ofstream&, MST&);
};

