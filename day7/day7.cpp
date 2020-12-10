#include <fstream>
#include <iostream>
#include <set>
#include <sstream>
#include <string>
#include <utility>
#include <vector>
using namespace std;

#define TARGET "shiny gold"

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

struct Bag {
  string color;
  string rules;
  vector<pair<Bag*, unsigned int>> children;

  Bag(string raw) {
    rules = parseColor(raw);
  }

  void addChild(Bag* b, unsigned int q) {
    bool has(false);
    for (auto c : children) {
      if (c.first->color == b->color) {
        has = true;
        break;
      }
    }
    if (!has) {
      children.push_back(pair<Bag*, unsigned int>(b, q));
    }
  }

  unsigned int countNested() {
    unsigned int nested(0);
    for (auto c : children) {
      nested += c.second + (c.second * c.first->countNested());
    }
    return nested;
  }

  bool hasChildOfColor(string color) {
    for (auto c : children) {
      if (c.first->color == color) {
        return true;
      }
    }
    return false;
  }

  void print() const {
    cout << "[BAG:" << color << "] -> ";
    for (auto c : children) {
      cout << c.first->color << " (" << c.second << ") ";
    }
    cout << endl;
  }

  string parseColor(string raw) {
    string cut("bags contain ");
    size_t pos = raw.find("bags contain ");
    color = rtrim(ltrim(raw.substr(0, pos)));
    raw = raw.substr(pos + cut.size());
    return raw.substr(0, raw.size() - 1);
  }

  void parseRules(vector<Bag>& bags) {
    string nextrule;
    istringstream ss(rules);
    while (getline(ss, nextrule, ',')) {
      nextrule = trim(nextrule);
      pair<unsigned int, string> specs = parseRule(nextrule);
      if (specs.first > 0) {
        for (size_t i=0; i<bags.size(); i++) {
          if (bags.at(i).color == specs.second) {
            addChild(&(bags.at(i)), specs.first);
            break;
          }
        }
      }
    }
  }

  pair<unsigned int, string> parseRule(string r) {
    pair<unsigned int, string> rule(0, "");

    istringstream ss(r);
    string token;

    getline(ss, token, ' ');
    if (token != "no") {
      rule.first = stoi(token);

      getline(ss, token);
      rule.second = token;
    }

    return rule;
  }

  string trim (const string& s) {
    string ns(ltrim(s));
    size_t end = ns.find(" bag");
    return rtrim(ns.substr(0, end));
  }

  string ltrim (const string& s) {
    size_t start = s.find_first_not_of(" ");
    return s.substr(start);
  }

  string rtrim (const string& s) {
    size_t end = s.find_last_not_of(" ");
    return s.substr(0, end + 1);
  }
};

void findTarget (string target, vector<Bag>& rules, set<Bag*>& results) {
  for (size_t i=0; i<rules.size(); i++) {
    if (rules.at(i).color != target && rules.at(i).hasChildOfColor(target)) {
      results.insert(&(rules.at(i)));
      findTarget(rules.at(i).color, rules, results);
    }
  }
}

unsigned int findNested(string target, vector<Bag>& rules) {
  unsigned int bags(0);
  for (auto b : rules) {
    if (b.color == target) {
      return b.countNested();
    }
  }
  return bags;
}

int main(int argc, char** argv) {
  cout << endl << "Day 7" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      // first pass -> make top-level bags
      vector<Bag> rules;
      for (auto c : contents) {
        if (c.size() > 0) {
          rules.push_back(Bag(c));
        }
      }

      // second pass -> add children (rules)
      for (auto &r : rules) {
        r.parseRules(rules);
      }

      // now ready to solve problems!
      set<Bag*> containers;
      findTarget(TARGET, rules, containers);
      cout << "Part 1: " << containers.size() << " bags can hold " << TARGET << endl;

      unsigned int nested = findNested(TARGET, rules);
      cout << "Part 2: " << TARGET << " bags have " << nested << " bags inside them" << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
