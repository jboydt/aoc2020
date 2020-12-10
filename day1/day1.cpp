#include <array>
#include <fstream>
#include <iostream>
#include <utility>
#include <vector>
using namespace std;

#define TARGET 2020
using uint = unsigned int;

vector<uint> slice(const vector<uint>& src, size_t pos) {
  vector<uint> front(src.begin(), src.begin() + pos);
  vector<uint> back(src.begin() + pos + 1, src.end());
  front.insert(front.end(), back.begin(), back.end());
  return front;
}

bool get_solution(const vector<uint>& values, pair<uint, uint>& p, uint target) {
  for (size_t i=0; i<values.size()-1; i++) {
    for (size_t j=i+1; j<values.size(); j++) {
      if (values.at(i) + values.at(j) == target) {
        p.first = values.at(i);
        p.second = values.at(j);
        return true;
      }
    }
  }
  return false;
}

bool get_solution(const vector<uint>& values, array<uint, 3>& t, uint target) {
  pair<uint, uint> p;
  for (size_t i=0; i<values.size()-1; i++) {
    vector<uint> tmp = slice(values, i);
    if (get_solution(tmp, p, target - values.at(i))) {
      t = {values.at(i), p.first, p.second};
      return true;
    }
  }
  return false;
}

int main(int argc, char** argv) {
  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    ifstream fin(argv[1]);
    if (fin.is_open()) {
      vector<uint> values;

      string nextline;
      while (getline(fin, nextline)) {
        if (nextline.size() > 0) {
          values.push_back(stoi(nextline));
        }
      }

      pair<uint, uint> duet;

      cout << "* PART ONE *" << endl << endl;
      if (get_solution(values, duet, TARGET)) {
        cout << "Got duet -> " << duet.first << ", " << duet.second << endl;
        cout << "Product  -> " << duet.first * duet.second << endl;
      } else {
        cout << "Unable to find solution" << endl;
      }
      cout << endl;

      array<uint, 3> triplet;

      cout << "* PART TWO *" << endl << endl;
      if (get_solution(values, triplet, TARGET)) {
        cout << "Got triplet -> " << triplet.at(0) << ", "
             << triplet.at(1) << ", " << triplet.at(2) << endl;
        cout << "Product  -> " << triplet.at(0) * triplet.at(1) * triplet.at(2) << endl;
      } else {
        cout << "Unable to find solution" << endl;
      }
      cout << endl;

      fin.close();
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  return 0;
}
