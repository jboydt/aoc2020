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

struct Password {
  bool valid;
  char key;
  unsigned int min;
  unsigned int max;
  string pass;

  Password(string encoded) {
    istringstream ss(encoded);

    string r;
    getline(ss, r, ' ');
    parseRange(r);

    string k;
    getline(ss, k, ' ');
    parseKey(k);

    getline(ss, pass);

    // cerr << "Password -> " << min << "-" << max << " " << key << ": "
    //      << pass << endl;

    validate();
  }

  void parseKey(string k) {
    key = k.at(0);
  }

  void parseRange(string r) {
    istringstream ss(r);
    string tmp;

    getline(ss, tmp, '-');
    min = stoi(tmp);

    getline(ss, tmp);
    max = stoi(tmp);
  }

  void validate() {
    unsigned int count(0);
    for (auto c : pass) {
      if (c == key) {
        count++;
      }
    }

    if (count >= min && count <= max) {
      valid = true;
    } else {
      valid = false;
    }
  }

  void revalidate() {
    unsigned int appears(0);
    if (pass.at(min - 1) == key) {
      appears++;
    }
    if (pass.at(max - 1) == key) {
      appears++;
    }

    if (appears == 1) {
      valid = true;
    } else {
      valid = false;
    }
  }
};

vector<Password> process(const vector<string>& contents) {
  vector<Password> passwords;
  for (auto p : contents) {
    passwords.push_back(Password(p));
  }
  return passwords;
}

unsigned int countValid(const vector<Password>& passwords) {
  unsigned int valid(0);
  for (auto p : passwords) {
    if (p.valid) {
      valid++;
    }
  }
  return valid;
}

unsigned int countRevalidated(vector<Password>& passwords) {
  unsigned int valid(0);
  for (auto p : passwords) {
    p.revalidate();
    if (p.valid) {
      valid++;
    }
  }
  return valid;
}

int main(int argc, char** argv) {
  cout << "Day 2" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      vector<Password> passwords = process(contents);
      unsigned int valid = countValid(passwords);
      cout << "Valid passwords (part 1): " << valid << endl;
      cout << endl;
      valid = countRevalidated(passwords);
      cout << "Valid passwords (part 2): " << valid << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
