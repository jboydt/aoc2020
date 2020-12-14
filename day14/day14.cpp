#include <bitset>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <utility>
#include <vector>
using namespace std;

bool readFile(string filename, vector<string>& contents) {
  contents.clear();

  ifstream fin(filename);
  if (fin.is_open()) {
    string nextline;
    while (getline(fin, nextline)) {
      contents.push_back(nextline);
    }
    fin.close();
    return true;
  } else {
    return false;
  }
}

size_t toInteger(string bits) {
  bitset<36> b;
  for (size_t i=0, j=b.size()-1; i<bits.size(); i++, j--) {
    if (bits.at(i) == '1') {
      b.set(j, 1);
    }
  }
  return b.to_ulong();
}

string parseMask(string input) {
  istringstream ss(input);
  string tmp;
  getline(ss, tmp, ' '); // skip mask
  getline(ss, tmp, ' '); // skip =
  getline(ss, tmp); // mask
  return tmp;
}

uint64_t applyMask(bitset<36>& bits, string mask) {
  // cout << "value:  " << bits << endl;
  // cout << "mask:   " << mask << endl;
  for (size_t i=0, j=mask.size()-1; i<mask.size(); i++, j--) {
    if (mask.at(i) == '0') {
      bits.set(j, 0);
    } else if (mask.at(i) == '1') {
      bits.set(j, 1);
    }
  }
  // cout << "result: " << bits << endl << endl;
  return bits.to_ulong();
}

string applyMaskV2(size_t addr, string mask) {
  string bits(bitset<36>(addr).to_string());
  for (size_t i=0; i<mask.size(); i++) {
    if (mask.at(i) == 'X') {
      bits.at(i) = 'X';
    } else if (mask.at(i) == '1') {
      bits.at(i) = '1';
    }
  }
  return bits;
}

bool isMemoryOp(string s) {
  return s.find("mem") != string::npos;
}

pair<size_t, bitset<36>> parseMem(string s) {
  pair<size_t, bitset<36>> result;

  istringstream ss(s);
  string tmp;
  getline(ss, tmp, '['); // skip mem
  getline(ss, tmp, ']'); // index
  result.first = stoi(tmp);
  size_t valpos = s.find_last_of(' ');
  tmp = s.substr(valpos);
  result.second = bitset<36>(stoi(tmp));

  return result;
}

pair<size_t, uint64_t> parseMemV2(string s) {
  pair<size_t, uint64_t> result;

  istringstream ss(s);
  string tmp;
  getline(ss, tmp, '['); // skip mem
  getline(ss, tmp, ']'); // index
  result.first = stoi(tmp);
  size_t valpos = s.find_last_of(' ');
  tmp = s.substr(valpos);
  result.second = stoi(tmp);

  return result;
}

void computeVariants(string bits, vector<size_t>& addr) {
  size_t xpos = bits.find('X');
  if (xpos == string::npos) {
    addr.push_back(toInteger(bits));
  } else {
    bits.at(xpos) = '0';
    computeVariants(bits, addr);
    bits.at(xpos) = '1';
    computeVariants(bits, addr);
  }
}

pair<uint64_t, vector<size_t>> parseFloatingMem(string input, string mask) {
  pair<uint64_t, vector<size_t>> result;

  pair<size_t, uint64_t> p = parseMemV2(input);
  result.first = p.second;

  string binary(applyMaskV2(p.first, mask));

  vector<size_t> addr;
  computeVariants(binary, addr);
  result.second = addr;

  return result;
}

int main(int argc, char** argv) {
  cout << endl << "Day 14" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      map<size_t, uint64_t> mem;
      string mask;
      for (auto c : contents) {
        if (isMemoryOp(c)) {
          pair<size_t, bitset<36>> p(parseMem(c));
          mem[p.first] = applyMask(p.second, mask);
        } else {
          mask = parseMask(c);
        }
      }

      uint64_t sum(0);
      for (auto kv : mem) {
        sum += kv.second;
      }
      cout << "Part 1: sum = " << sum << endl;

      mem.clear();
      mask.clear();
      for (auto c: contents) {
        if (isMemoryOp(c)) {
          pair<uint64_t, vector<size_t>> p = parseFloatingMem(c, mask);
          for (auto a : p.second) {
            mem[a] = p.first;
          }
        } else {
          mask = parseMask(c);
        }
      }

      sum = 0;
      for (auto kv : mem) {
        sum += kv.second;
      }
      cout << "Part 2: sum = " << sum << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
