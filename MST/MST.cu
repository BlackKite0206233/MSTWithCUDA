#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <cmath>
#include "MST.h"

#define MAX_NUM 100000
#define THREAD_PER_BLOCK 1024

__device__ int find(int x, int *p) {
    return x == p[x] ? x : (p[x] = find(p[x], p));
}

__device__ void Union(int x, int y, int *p) {
    p[find(x, p)] = find(y, p);
}

__global__ void init(int *d, int *e) {
    long long int index = threadIdx.x + blockIdx.x * blockDim.x;
    d[index] = MAX_NUM;
    e[index] = 0;
}

__global__ void smt(int *cross_dege, int *d, int *e, int *p, Edge *edge) {
    long long int index = threadIdx.x + blockIdx.x * blockDim.x;
    int x = find(edge[index].x, p);
    int y = find(edge[index].y, p);
    int weight = edge[index].weight;
    if(x != y) {
        (*cross_dege)++;
        if(weight < d[x] || weight == d[x] && index < e[x])
            d[x] = weight, e[x] = index;
        if(weight < d[y] || weight == d[y] && index < e[y])
            d[y] = weight, e[y] = index;
    }
   
}

__global__ void merge(int *d, int *e, int *p, Edge *edge) {
    long long int index = threadIdx.x + blockIdx.x * blockDim.x;
    if(d[index] != MAX_NUM)
        Union(edge[e[index]].x, edge[e[index]].y, p);
}


MST::MST(int _vNum, int _eNum) : count(0) {
    this->vNum = abs(_vNum);
    this->eNum = abs(_eNum);

    this->p = new int[this->vNum];
    for(int i = 0; i < this->vNum; i++)
        this->p[i] = i;

    this->edge = new Edge[this->eNum];
}

MST::~MST() {
    delete[] this->p;
    delete[] this->edge;
}

void MST::addEdge(int _x, int _y, int _weight) {
    if(count < this->eNum && _x >= 0 && _x < this->vNum && _y >= 0 && _y < this->vNum) {
        this->edge[count].x = _x;
        this->edge[count].y = _y;
        this->edge[count].weight = _weight;
        count++;
    }
}

void MST::cal() {
    int *v_d, *e_d, *p_d;
    Edge *edge_d;

    int *v = new int[this->vNum];
    int *e = new int[this->vNum];

    cudaMalloc((int **)&v_d, sizeof(int) * this->vNum);
    cudaMalloc((int **)&e_d, sizeof(int) * this->vNum);
    cudaMalloc((int **)&p_d, sizeof(int) * this->vNum);
    cudaMalloc((Edge **)&edge_d, sizeof(Edge) * this->eNum);

    cudaMemcpy(p_d, this->p, sizeof(int) * this->vNum, cudaMemcpyHostToDevice);
    cudaMemcpy(edge_d, this->edge, sizeof(Edge) * this->eNum, cudaMemcpyHostToDevice);

    while(true) {
        int cross_edge = 0;

        init<<<this->vNum / THREAD_PER_BLOCK + 1, THREAD_PER_BLOCK>>>(v_d, e_d);

        
        cudaMemcpy(v, v_d, sizeof(int) * this->vNum, cudaMemcpyDeviceToHost);
        cudaMemcpy(e, e_d, sizeof(int) * this->vNum, cudaMemcpyDeviceToHost);
        cudaMemcpy(this->p, p_d, sizeof(int) * this->vNum, cudaMemcpyDeviceToHost);

        for(int i = 0; i < this->vNum; i++) 
            cout << v[i] << " " << e[i] << " " << this->p[i] << endl;
            

        smt<<<this->vNum / THREAD_PER_BLOCK + 1, THREAD_PER_BLOCK>>>(&cross_edge, v_d, e_d, p_d, edge_d);

        if(cross_edge == 0)
            break;

        merge<<<this->vNum / THREAD_PER_BLOCK + 1, THREAD_PER_BLOCK>>>(v_d, e_d, p_d, edge_d);
    }

    cudaMemcpy(this->p, p_d, sizeof(int) * this->vNum, cudaMemcpyDeviceToHost);    
    cudaFree(v_d);
    cudaFree(e_d);
    cudaFree(p_d);
    cudaFree(edge_d);
}

ofstream& operator <<(ofstream& _ofs, MST& _smt) {
    for(int i = 0; i < _smt.vNum; i++) 
        _ofs << "point " << i << " connect to point " << _smt.p[i] << endl;

    return _ofs;
}

