#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
using namespace std;

int getHammingDistance(string a, string b) {
	int ret = 0;
	for (int x = 0; x < a.length(); x++) {
		if (a[x] != b[x]) {
			ret++;
		}
	}
	return ret;
}

int main() {
	unordered_map<int, int> map;
	string read, firstham, lastham;
	string filename;
	int i = 0;

	for (int i = 1; i < 51; i++) {
		firstham.clear();
		filename = to_string(i);
		filename += ".hex";
		fstream f(filename);

		if (!f) {
			cout << "Failed to read file!\n";
			return 0;
		}
		cout << i << ": ";
		for (int i = 1; i < 65; i++) {
			f >> read;
			cout << read[10];
			firstham += read[10];
		}
		if (i > 1) {
			int ham = getHammingDistance(firstham, lastham);
			cout << " Hamming Distance is: " << ham;
			map[ham]++;
		}
		cout << endl;
		lastham = firstham;
		f.close();
	}

	for (unordered_map<int, int>::const_iterator it = map.begin(); it != map.end(); it++) {
		cout << "Number of " << it->first << " Hamming Distances is " << it->second << endl;
	}

	return 0;
}
