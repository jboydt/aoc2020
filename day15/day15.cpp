#include <bitset>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <utility>
#include <vector>
using namespace std;

#define LAST_TURN 30000000

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

void init(map<int, array<int, 2>>& numbers, string input) {
  istringstream ss(input);
  string next;
  size_t pos(1);
  while (getline(ss, next, ',')) {
    numbers[stoi(next)][1] = pos++;
  }
}

void process(map<int, array<int, 2>>& numbers) {
  int nextTurn = numbers.size() + 1;
  int last(0);
  for (auto kv : numbers) {
    if (kv.second[1] == nextTurn - 1) {
      last = kv.first;
      break;
    }
  }
  for (int i=nextTurn; i<=LAST_TURN; i++) {
    if (numbers[last][0] == 0) {
      numbers[0][0] = numbers[0][1];
      numbers[0][1] = i;
      last = 0;
    } else {
      int num = numbers[last][1]-numbers[last][0];
      numbers[num][0] = numbers[num][1];
      numbers[num][1] = i;
      last = num;
    }
  }
}

int findLast(const map<int, array<int, 2>>& numbers) {
  for (auto kv : numbers) {
    if (kv.second[1] == LAST_TURN) {
      return kv.first;
    }
  }
  return -1;
}

int main(int argc, char** argv) {
  cout << endl << "Day 15" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      map<int, array<int, 2>> numbers;
      init(numbers, contents.at(0));
      process(numbers);
      int value = findLast(numbers);
      cout << "Part 2: value at turn " << LAST_TURN << " = " << value << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
