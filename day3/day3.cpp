#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
using namespace std;

bool readFile(string filename, vector<string>& contents) {
  contents.clear();

  ifstream fin(filename);
  if (fin.is_open()) {
    string nextline;
    while (getline(fin, nextline)) {
      if (nextline.size() > 0) {
        contents.push_back(nextline);
      }
    }
    fin.close();
    return true;
  } else {
    return false;
  }
}

unsigned int countTrees(const vector<string>& map, unsigned int down, unsigned int right) {
  vector<string> tmap(map);
  unsigned int trees(0);

  size_t row(down), col(right);
  while (row < tmap.size()) {
    // cerr << "Checking row=" << row << ", col=" << col << endl;
    if (col >= tmap.at(row).size()) {
      for (size_t i=row; i<tmap.size(); i++) {
        tmap.at(i) += map.at(i);
      }
    }

    if (tmap.at(row).at(col) == '#') {
      trees++;
    }

    row += down;
    col += right;
  }

  return trees;
}

int main(int argc, char** argv) {
  cout << "Day 3" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      unsigned int trees1 = countTrees(contents, 1, 3);
      cout << "Part 1: " << trees1 << " trees on the slope" << endl;
      cout << endl;

      unsigned int trees2 = countTrees(contents, 1, 1);
      unsigned int trees3 = countTrees(contents, 1, 5);
      unsigned int trees4 = countTrees(contents, 1, 7);
      unsigned int trees5 = countTrees(contents, 2, 1);
      unsigned int product = trees1 * trees2 * trees3 * trees4 * trees5;
      // cout << "s1=" << trees2 << ", s2=" << trees1 << ", s3=" << trees3
      //      << ", s4=" << trees4 << ", s5=" << trees5 << endl;
      cout << "Part 2: " << product << " is the product of all slopes" << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
