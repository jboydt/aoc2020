#include <fstream>
#include <iostream>
#include <unordered_map>
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

struct Rule {
  string label;
  array<int, 4> ranges;

  Rule (string input) {
    istringstream ss(input);
    getline(ss, label, ':');

    string tmp;
    getline(ss, tmp, ' '); // skip the space after label:
    getline(ss, tmp, ' '); // first range
    parseRange(tmp, 0, 1);
    getline(ss, tmp, ' '); // skip or
    getline(ss, tmp); // second range
    parseRange(tmp, 2, 3);
  }

  void parseRange(string range, int i1, int i2) {
    istringstream ss(range);
    string tmp;
    getline(ss, tmp, '-');
    ranges[i1] = stoi(tmp);
    getline(ss, tmp);
    ranges[i2] = stoi(tmp);
  }

  bool inRange(int value) const {
    return inLower(value) || inUpper(value);
  }

  bool inLower(int value) const {
    return value >= ranges[0] && value <= ranges[1];
  }

  bool inUpper(int value) const {
    return value >= ranges[2] && value <= ranges[3];
  }
};

struct Ticket {
  vector<int> values;

  Ticket(string input) {
    istringstream ss(input);
    string next;
    while (getline(ss, next, ',')) {
      values.push_back(stoi(next));
    }
  }
};

void loadRules(const vector<string>& contents, vector<Rule>& rules) {
  for (auto c : contents) {
    if (c.find("your ticket") != string::npos) {
      break;
    }

    if (c.size() > 0) {
      rules.push_back(Rule(c));
    }
  }
}

void loadTickets(const vector<string>& contents, vector<Ticket>& tickets) {
  size_t i(0);
  while (contents.at(i).find("your ticket") == string::npos) {
    i++;
  }

  for (i; i<contents.size(); i++) {
    if (contents.at(i).size() > 0 && contents.at(i).find("ticket") == string::npos) {
      tickets.push_back(Ticket(contents.at(i)));
    }
  }
}

bool validForAny(int value, const vector<Rule>& rules) {
  bool valid(false);
  for (auto r : rules) {
    if (r.inRange(value)) {
      valid = true;
      break;
    }
  }
  return valid;
}

vector<int> validate(const vector<Ticket>& tickets,
                     const vector<Rule>& rules,
                     vector<Ticket>& goodTickets) {
  vector<int> result;
  // skip the first ticket -- that is mine
  for (size_t i=1; i<tickets.size(); i++) {
    bool keep(true);
    for (auto tv : tickets.at(i).values) {
      if (!validForAny(tv, rules)) {
        result.push_back(tv);
        keep = false;
      }
    }
    if (keep) {
      goodTickets.push_back(tickets.at(i));
    }
  }
  return result;
}

void removeRule(unordered_map<int, vector <int>>& matrix, int rule) {
  cerr << "removing rule " << rule << endl;
  for (auto& col : matrix) {
    for (size_t i=0; i<col.second.size(); i++) {
      if (col.second.size() == 1) continue;
      if (col.second[i] == rule) {
        col.second.erase(col.second.begin() + i);
      }
    }
  }
}

bool processMatrix(unordered_map<int, vector <int>>& matrix, unordered_map<int, bool>& proc) {
  for (auto& col : matrix) {
    if (col.second.size() == 1 && !proc[col.first]) {
      proc[col.first] = true;
      removeRule(matrix, col.second[0]);
      return true;
    }
  }
  return false;
}

bool meetsRule(const vector<Ticket>& tickets, const vector<Rule>& rules, int ticket, int rule) {
  for (auto t : tickets) {
    if (!rules[rule].inRange(t.values[ticket])) {
      return false;
    }
  }
  return true;
}

void determineFieldOrder(const vector<Ticket>& tickets,
                         const vector<Rule>& rules,
                         unordered_map<int, string>& fields) {
  unordered_map<int, vector <int>> matrix;
  unordered_map<int, bool> proc;

  for (size_t t=0; t<rules.size(); t++) {
    proc[t] = false;
    for (size_t r=0; r<rules.size(); r++) {
      if (meetsRule(tickets, rules, t, r)) {
        matrix[t].push_back(r);
      }
    }
  }

  while(processMatrix(matrix, proc)) {}

  for (auto col : matrix) {
    fields[col.first] = rules[col.second[0]].label;
  }
}

ulong combineFields(const Ticket& t, const unordered_map<int, string>& fields) {
  ulong product(1);
  for (auto kv : fields) {
    if (kv.second.find("departure") == 0) {
      product *= t.values[kv.first];
    }
  }

  return product;
}

int main(int argc, char** argv) {
  cout << endl << "Day 16" << endl << endl;

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " FILENAME" << endl;
  } else {
    vector<string> contents;
    if (readFile(argv[1], contents)) {
      vector<Rule> rules;
      vector<Ticket> tickets;
      loadRules(contents, rules);
      loadTickets(contents, tickets);
      vector<Ticket> goodTickets;
      vector<int> invalid = validate(tickets, rules, goodTickets);
      int sum(0);
      for (auto i : invalid) {
        sum += i;
      }
      cout << "Part 1: scanning error rate = " << sum << endl;

      unordered_map<int, string> fields;
      determineFieldOrder(goodTickets, rules, fields);
      ulong product = combineFields(tickets.at(0), fields);
      cout << "Part 2: product of departure fields = " << product << endl;
    } else {
      cout << "Unable to open " << argv[1] << endl;
    }
  }

  cout << endl;

  return 0;
}
