/******************************************************
********** Program Name : Smith_Waterman    ***********
********** Programmer   : LEE CHENG-LIN     ***********
******************************************************/
#include <iostream> //std::cout
#include <iomanip>
#include <ostream>  
#include <fstream>
#include <sstream>
#include <cstdio>
#include <vector>
#include <queue>
#include <climits>
#include <map>
#include <bitset>


using namespace std;
typedef pair<char, char> comp;
void smith_Waterman(int& maxp, int& maxq, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut);
int sw_vmatrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut);
int sw_ematrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut);
int sw_fmatrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut);

void traceback(int maxp, int maxq, vector<char>& out1, vector<char>& out2 ,vector<char>& seq1, vector<char>& seq2, int** swv, char** trace_table);
int main(int argc, char** argv)
{
    // Hardware pattern
    // fstream output_pattern;
    fstream output_answer;
    fstream output_vmatrix;
    fstream output_ematrix;
    fstream output_fmatrix;
    // output_pattern.open("in.pattern", ios::out);
    output_answer.open("out_golden.pattern", ios::out);
    output_vmatrix.open("vmatrix.csv", ios::out);
    output_ematrix.open("ematrix.csv", ios::out);
    output_fmatrix.open("fmatrix.csv", ios::out);
    // Input file
    ifstream in_sequence (argv[1]);
    ifstream in_lut (argv[2]);
    if(!in_sequence.is_open()) {
        cout << "Open comparing sequence failed." << endl;
        return 0;
    }
    if(!in_lut.is_open()) {
        cout << "Open look up table failed." << endl;
        return 0;
    }     

          // Look up table key!

    // Input file translation
    int             alpha = 2, beta = 1;
    int             maxp, maxq;         
    int             len_seq1, len_seq2;
    int             len_lut;
    vector<char>    out1, out2;
    int**           sw_table;
    int**           swe;
    int**           swf;
    char**          trace_table;
    map<comp, int>  lut;
    
    string  line;

    getline(in_sequence, line);
    len_seq1 = line.size()-1;
    vector<char> seq1(line.c_str(), line.c_str() + len_seq1);
    cout << "seq1.size(): " << seq1.size()  << endl;
    // cout << "len_seq1: " << len_seq1 << endl; 
    // for(int i = 0; i < seq1.size(); i++) {
    //     cout << i << " " <<seq1[i] << endl;
    // }

    getline(in_sequence, line);
    len_seq2 = line.size()-1;
    vector<char> seq2(line.c_str(), line.c_str() + len_seq2);
    cout << "seq2.size(): " << seq2.size()  << endl;
    // cout << "len_seq2: " << len_seq2 << endl; 
    // for(int i = 0; i < seq2.size(); i++) {
    //     cout << i << " " <<seq2[i] << endl;
    // }
    


    sw_table = new int*[len_seq1];
    swe      = new int*[len_seq1];
    swf      = new int*[len_seq1];
    trace_table = new char*[len_seq1];
    for(int i = 0; i < len_seq1; i++) {
        sw_table[i] = new int[len_seq2];
        swe[i]      = new int[len_seq2];
        swf[i]      = new int[len_seq2];
        trace_table[i] = new char[len_seq2];
        for(int j = 0; j < len_seq2; j++) {
            sw_table[i][j]  = INT_MAX;
            swe[i][j]       = INT_MAX;
            swf[i][j]       = INT_MAX;
            /*if(i == 0 || j ==0) {
                sw_table[i][j]  = 0;
                swe[i][j]       = 0;
                swf[i][j]       = 0;
            }*/
        }
    }

    getline(in_lut, line, '\n');
    len_lut = line.size() - 1;
    vector<char> lut_seq(line.c_str(), line.c_str() + len_lut);

    //debug start
    // cout << "lut_seq size" << lut_seq.size() << endl; 
    // for(int i = 0; i < lut_seq.size(); i++) {
    //     cout << i << " " <<lut_seq[i] << endl;
    // }
    //debug end

    
    int exam1 = 0;
    while(getline(in_lut, line, '\n')) {
        exam1 ++;
        if(exam1 > len_lut) {
            cout << "Look up table format error" << endl;
            return 0;
        }
        int             exam2 = 0;
        istringstream   templine(line);
        string          value;
        while( getline(templine, value, ',')) {
            exam2 ++;
            comp tempcomp(lut_seq[exam1-1],lut_seq[exam2-1]);
            lut[tempcomp] = stoi(value);
            if( exam2 > len_lut) {
                //cout << "bigger exam2: " << exam2 << "len_lut: " << len_lut << endl;
                cout << "Look up table format error" << endl;
                return 0;
            }
        }
        if( exam2 < len_lut) {
            //cout << "exam2: " << exam2 << "len_lut: " << len_lut << endl;
            cout << "Look up table format error" << endl;
            return 0;
        }

    }
    //cout << "Map size: " << lut.size() << endl;
    smith_Waterman(maxp,maxq,alpha,beta,seq1,seq2,sw_table,swe,swf,trace_table,lut);
    traceback(maxp,maxq,out1,out2,seq1,seq2,sw_table,trace_table);
    //cout << "traceback complete" << endl;
#ifdef PRINT
    for(int i =  out1.size() -1 ; i >=0 ; i--) {
        cout << out1[i] << " " ;
    }
    cout << endl;
    for(int i =  out2.size() -1 ; i >=0 ; i--) {
        cout << out2[i] << " " ;
    }
    cout << endl;
    cout << "out1.size(): " << out1.size() << " out2.size(): " << out2.size() << endl;
#endif
    cout << "Max score: " << sw_table[maxp][maxq] << endl;
    //cout << "V Matrix" << endl;
#ifdef PRINT
    for(int k = 0; k < len_seq2; k++) output_vmatrix << k + 1 << ',';
    output_vmatrix << endl;
    for(int i = 0; i < len_seq1; i++) { // T
        for(int j = 0; j < len_seq2; j++) { // S
            output_vmatrix << setw(3) <<sw_table[i][j] <<',';
        }
        output_vmatrix << endl;
    }
    for(int k = 0; k < len_seq2; k++) output_ematrix << k + 1 << ',';
    output_ematrix << endl;
    for(int i = 0; i < len_seq1; i++) { // T
        for(int j = 0; j < len_seq2; j++) { // S
            output_ematrix << setw(3) <<swe[i][j] <<',';
        }
        output_ematrix << endl;
    }
    for(int k = 0; k < len_seq2; k++) output_fmatrix << k + 1 << ',';
    output_fmatrix << endl;
    for(int i = 0; i < len_seq1; i++) { // T
        for(int j = 0; j < len_seq2; j++) { // S
            output_fmatrix << setw(3) <<swf[i][j] <<',';
        }
        output_fmatrix << endl;
    }

#endif
    // cout <<  "E Matrix" << endl;
    // for(int i = 0; i < len_seq1; i++) {
    //     for(int j = 0; j < len_seq2; j++) {
    //         cout << setw(3) <<swe[i][j] <<' ';
    //     }
    //     cout << endl;
    // }
    // cout <<  "F Matrix" << endl;
    // for(int i = 0; i < len_seq1; i++) {
    //     for(int j = 0; j < len_seq2; j++) {
    //         cout << setw(3) <<swf[i][j] <<' ';
    //     }
    //     cout << endl;
    // }
    // output_pattern << "00 00\n";
    // for(int i = 0; i < seq1.size(); i++) {
    //     output_pattern << "01 ";
    //     switch(seq1[i]){
    //         case 'A': output_pattern << "00\n"; break;
    //         case 'T': output_pattern << "01\n"; break;
    //         case 'C': output_pattern << "10\n"; break;
    //         case 'G': output_pattern << "11\n"; break;
    //     }
    // }
    // for(int j = 0; j < seq2.size(); j++) {
    //     output_pattern << "10 ";
    //     switch(seq1[j]){
    //         case 'A': output_pattern << "00\n"; break;
    //         case 'T': output_pattern << "01\n"; break;
    //         case 'C': output_pattern << "10\n"; break;
    //         case 'G': output_pattern << "11\n"; break;
    //     }
    // }
    // output_pattern << "11 00\n";
    output_answer << bitset<16>(sw_table[maxp][maxq]).to_string();
    


    
    return 0;

} 

void traceback(int maxp, int maxq, vector<char>& out1, vector<char>& out2 ,vector<char>& seq1, vector<char>& seq2, int** swv, char** trace_table) {

    // for(int i = 0; i < maxp; i++ ) {
    //     for(int j = 0; j < maxq; j++) {
    //         cout << setw(2) << trace_table[i][j];
    //     }
    //     cout << endl;
    // }
    while(swv[maxp][maxq] != 0 ) {
        //cout << "maxp: " << maxp << " maxq: " << maxq << endl; 
        switch (trace_table[maxp][maxq])
        {
            case 'u':
                out1.push_back('-');
                out2.push_back(seq2[maxq]); 
                maxq--;   
            break;
            case 'l':
                out1.push_back(seq1[maxp]);
                out2.push_back('-'); 
                maxp--;
            break;
            case 'o':
                out1.push_back(seq1[maxp]);
                out2.push_back(seq2[maxq]);
                maxp--;
                maxq--;
            break;
        }
        if(maxq < 0 || maxp <0) break;
    }
        //cout << "maxp: " << maxp << " maxq: " << maxq << endl; 

    
};
void smith_Waterman(int& maxp, int& maxq, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut) {
    int tempmax = 0;
    for(int i = 0; i < seq1.size(); i++) {
        for(int j = 0; j < seq2.size(); j++) {
            //cout << "i:" << i << " j: " << j <<endl;
            int temp = sw_vmatrix(i,j,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut);
            
            if( temp > tempmax) {
                maxp = i;
                maxq = j;
                tempmax = temp;
            }
        }
    }
};  

int sw_vmatrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut)  {
    if(p == -1 || q == -1) return 0;
    if(swv[p][q] != INT_MAX) return swv[p][q];
    int tempe = sw_ematrix(p,q,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut);
    int tempf = sw_fmatrix(p,q,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut);
    int tempv = sw_vmatrix(p-1,q-1,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut);
    comp tempcomp(seq1[p],seq2[q]);
    int com_value = lut[tempcomp];

    swv[p][q] = 0;
    //cout << "failed?" << endl;
    //cout << "p: " << p << " q: " << q << endl;
    trace_table[p][q] = 's'; //stop
    //cout << "failed?" << endl;

    if(swv[p][q] < tempe) {
        swv[p][q] =tempe;
        trace_table[p][q] = 'u'; // up
    } 
    if(swv[p][q] < tempf) {
        swv[p][q] = tempf;
        trace_table[p][q] = 'l'; //left
    } 
    if(swv[p][q] < tempv + com_value) {
        swv[p][q] = tempv + com_value;
        trace_table[p][q] = 'o'; //oblique
    } 
    if(swv[p][q] < 0 ) swv[p][q] = 0;
    return swv[p][q];
};
int sw_ematrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut) {
    if(p == -1 || q == -1) return 0;
    if(swe[p][q] != INT_MAX) return swe[p][q];
    int tempv = sw_vmatrix(p,q-1,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut) - alpha;
    int tempe = sw_ematrix(p,q-1,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut) - beta;
    if(tempe < tempv ) swe[p][q] = tempv;
    else { swe[p][q] = tempe; }
    if(swe[p][q] < 0 ) swe[p][q] = 0;
    return swe[p][q];
};
int sw_fmatrix(int p, int q, int alpha, int beta, vector<char>& seq1,  vector<char>& seq2, int** swv, int** swe, int** swf, char** trace_table, map<comp, int>& lut) {
    if(p == -1 || q == -1) return 0;
    if(swf[p][q] != INT_MAX) return swf[p][q];
    int tempv = sw_vmatrix(p-1,q,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut) - alpha;
    int tempf = sw_fmatrix(p-1,q,alpha,beta,seq1,seq2,swv,swe,swf,trace_table, lut) - beta;
    if(tempf < tempv ) swf[p][q] = tempv;
    else { swf[p][q] = tempf; }
    if(swf[p][q] < 0 ) swf[p][q] = 0;
    return swf[p][q];
};
