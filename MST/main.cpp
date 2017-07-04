#include <iostream>
#include <fstream>
#include <random>
#include <time.h>
#include "MST.h"

#define MAX_WEIGHT 10000

using namespace std;

int main() {
    srand(time(NULL));

    fstream fs("input.txt");
    ofstream ofs("output.txt");
    int vNum, eNum;

    if(fs.is_open()) {
        fs >> vNum >> eNum;
        MST smt(vNum, eNum);

        while(eNum--)
            smt.addEdge(rand() % vNum, rand() % vNum, (rand() % MAX_WEIGHT) * (rand() % 10 < 7 ? 1 : -1));

        smt.cal();
        
        ofs << smt;
    } else 
        cout << "could not open the file" << endl;

    fs.close();
    ofs.close();

    return 0;
}