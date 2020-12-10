#include <array>
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
      contents.push_back(nextline);
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

struct Passport {
  unsigned int byr;
  unsigned int iyr;
  unsigned int eyr;
  string hgt;
  string hcl;
  string ecl;
  string pid;
  string cid;
  bool valid;

  Passport(string data)
  : byr(0), iyr(0), eyr(0), valid(false) {
    istringstream ss(data);
    // cerr << "parsing -> " << data << endl;
    string nextField;
    while (getline(ss, nextField, ' ')) {
      parse(nextField);
    }
    validate();
  }

  void parse(string field) {
    string label(field.substr(0, 3));
    string data(field.substr(4));

    if (label == "byr") {
      byr = stoi(data);
    } else if (label == "iyr") {
      iyr = stoi(data);
    } else if (label == "eyr") {
      eyr = stoi(data);
    } else if (label == "hgt") {
      hgt = data;
    } else if (label == "hcl") {
      hcl = data;
    } else if (label == "ecl") {
      ecl = data;
    } else if (label == "pid") {
      pid = data;
    } else if (label == "cid") {
      cid = data;
    }
  }

  void validate() {
    unsigned int invalid(0);
    if (byr < 1920 || byr > 2002) {
      invalid++;
      // cerr << "byr failed" << endl;
    }
    if (iyr < 2010 || iyr > 2020) {
      invalid++;
      // cerr << "iyr failed" << endl;
    }
    if (eyr < 2020 || eyr > 2030) {
      invalid++;
      // cerr << "eyr failed" << endl;
    }
    if (!validHeight()) {
      invalid++;
      // cerr << "hgt failed" << endl;
    }
    if (!validHairColor()) {
      invalid++;
      // cerr << "hcl failed" << endl;
    }
    if (!validEyeColor()) {
      invalid++;
      // cerr << "ecl failed" << endl;
    }
    if (!validPid()) {
      invalid++;
      // cerr << "pid failed" << endl;
    }

    if (invalid == 0) {
      valid = true;
    } else {
      valid = false;
    }
  }

  bool validEyeColor() {
    if (ecl.size() == 0) return false;

    array<string, 7> colors = {"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
    for (auto c : colors) {
      if (ecl == c) {
        return true;
      }
    }
    return false;
  }

  bool validHairColor() {
    if (hcl.size() == 0) return false;

    if (hcl.at(0) != '#') {
      return false;
    } else if (hcl.size() != 7) {
      return false;
    } else {
      string valids("0123456789abcdef");
      for (size_t i=1; i<hcl.size(); i++) {
        bool isValid(false);
        for (auto n : valids) {
          if (hcl.at(i) == n) {
            isValid = true;
            break;
          }
        }
        if (!isValid) {
          return false;
        }
      }
    }
    return true;
  }

  bool validHeight() {
    if (hgt.size() == 0) return false;

    size_t pos(0);
    while (pos < hgt.size() && isdigit(hgt.at(pos))) pos++;

    if (pos == hgt.size()) return false;

    unsigned int height(stoi(hgt.substr(0, pos)));
    string sys(hgt.substr(pos));
    if (sys == "cm" && height >= 150 && height <= 193) {
      return true;
    } else if (sys == "in" && height >= 59 && height <= 76) {
      return true;
    }
    return false;
  }

  bool validPid() {
    if (pid.size() == 0) return false;

    if (pid.size() != 9) {
      return false;
    }
    for (auto p : pid) {
      if (!isdigit(p)) {
        return false;
      }
    }
    return true;
  }

  void print() {
    cout << "byr[" << byr << "] "
         << "iyr[" << iyr << "] "
         << "eyr[" << eyr << "] "
         << "hgt[" << hgt << "] "
         << "hcl[" << hcl << "] "
         << "ecl[" << ecl << "] "
         << "pid[" << pid << "] "
         << "cid[" << cid << "] "
         << "valid[" << boolalpha << valid << "]"
         << endl;
  }
};

vector<string> collapse(const vector<string>& contents) {
  vector<string> collapsed;

  string entry;
  for (auto s : contents) {
    if (s.size() > 0) {
      entry += s + " ";
    } else {
      collapsed.push_back(entry.substr(0, entry.size() - 1));
      entry = "";
    }
  }
  collapsed.push_back(entry);

  return collapsed;
}

unsigned int countValid(const vector<Passport>& passports) {
  unsigned int valid(0);
  for (auto p : passports) {
    if (p.valid) {
      valid++;
    }
  }
  return valid;
}

int main(int argc, char** argv) {
  cout << "Day 3" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      vector<string> fixed = collapse(contents);
      vector<Passport> passports;
      for (auto f : fixed) {
        Passport p(f);
        passports.push_back(p);
        // p.print();
      }

      unsigned int valid = countValid(passports);
      cout << "Part 1 and 2: " << valid << "/" << passports.size() << " valid" << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
