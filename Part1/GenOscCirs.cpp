#include <iostream>
#include <random>
#include <tuple>

auto main() -> int {
	constexpr size_t total_inverters = 12;
	std::random_device rd{};
	std::mt19937 rng{ rd() };
	std::normal_distribution distribution{1.0, 0.05};

	auto in_range = [](auto x, auto mu, auto k)
	{ return (mu - k) <= x && x <= (mu + k); };

	auto get_random = [&distribution, &rng, in_range](auto range) {
		double t;
		do {
			t = distribution(rng);
		} while (!in_range(t, 1, range));
		return t;
	};

	auto get_size_variations = [get_random]() {
		return std::make_tuple(get_random(0.15), get_random(0.15),
			get_random(0.15), get_random(0.15));
	};

	auto get_thickness_variations = [get_random]() {
		return std::make_tuple(get_random(0.10), get_random(0.10));
	};

	std::cout << "*Oscillator\n" 
		<< std::endl << "*Imports\n" 
		<< ".include ./NAND.cir\n" 
		<< ".include ./inverter.cir\n" << std::endl;
	std::cout << "*Declare subckt\n" << ".subckt oscillator(INSERT NUM HERE) en n12\n"
		<< "x0 en n12 n0 NAND\n";

	// generate inverters
	for (size_t i = 0; i < total_inverters; i++) {
		auto [tplv, tpwv, tnln, tnwn] = get_size_variations();
		auto [tpotv, tnotv] = get_thickness_variations();
		std::cout
			<< "x" << (i + 1) << " n" << i << " n" << (i + 1) << " inverter"
			<< " plen=" << tplv*70 << "n pwid=" << tpwv*220
			<< "n nlen=" << tnln*70 << "n nwid=" << tnwn*130
			<< "n ptox=" << tpotv*1.95 << "n ntox=" << tnotv*1.85 << "n"
			<< std::endl;
	}
	std::cout << "\n.ends oscillator\n";
	return 0;
}
