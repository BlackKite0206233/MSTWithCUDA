#pragma once
#include <cmath>
#include "MST.h"




MST::MST(int _vNum, int _eNum) : count(0) {
    this->vNum = abs(_vNum);
    this->eNum = abs(_eNum);

    this->v = new int[this->vNum];
    this->p = new int[this->vNum];

    this->e = new Edge[this->eNum];
}

MST::~MST() {
    delete[] this->v;
    delete[] this->p;
    delete[] this->e;
}

void MST::addEdge(int _x, int _y, int _weight) {
    if(count < this->eNum && _x >= 0 && _x < this->vNum && _y >= 0 && _y < this->vNum) {
        this->e[count].x = _x;
        this->e[count].y = _y;
        this->e[count].weight = _weight;
        count++;
    }
}

void MST::cal() {

}

ofstream& operator <<(ofstream& _ofs, MST& _smt) {
    for(int i = 0; i < _smt.vNum; i++) 
        _ofs << "point " << i << " connect to point " << _smt.p[i] << endl;

    return _ofs;
}

