#include <fstream>
#include <iostream>
#include <vector>
#include <string>
using namespace std;

bool isRising(double voltprev, double volt) {		//Check if voltage value is rising (>=0.8V is assumed high)
	if (volt >= 0.8 && voltprev < 0.8) return 1;
	return 0;
}

int main() {
	double time, en, oscval;
	vector<vector<double>> osc;
	vector<int> count(8, 0);
	string line;
	int i = 1;
	fstream f("oscillator_data.txt");

	if (!f) {
		cout << "Failed to read file!\n";
		return 0;
	}

	getline(f, line);			//Read column names to get them out of the way
	f >> time >> en;			//Read first 2 data points since we are not processing them
	osc.push_back(vector<double>());
	for (int x = 0; x < 8; x++) {		//Read 8 osc voltage values and push into 2D vector
		f >> oscval;
		osc[0].push_back(oscval);
	}

	while (f) {
		f >> time >> en;		//Always read 2 data points to being reading osc vals (depending on how ngspice output file is formatted)
		osc.push_back(vector<double>());
		for (int x = 0; x < 8; x++) {	//Read and push current osc values in 2D vector
			f >> oscval;
			osc[i].push_back(oscval);
		}

		cout << i << " ";		// Increment count when rising edge is detected per oscillator
		for (int x = 0; x < 8; x++) {
			count[x] += isRising(osc[i - 1][x], osc[i][x]);
			cout << count[x] << " ";
		}
		cout << endl;

		i++;
	}
	f.close();

	return 0;
}
