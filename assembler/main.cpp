#include <iostream>
#include "assembler.hpp"
#include <fstream>
#include <iomanip>

int main(int argc, char** argv) {
    if (argc != 3) { std::cerr << "usage: tasm <in.asm> <out.hex>\n"; return 1; }
    std::ifstream in(argv[1]);
    std::string src((std::istreambuf_iterator<char>(in)),
                     std::istreambuf_iterator<char>());
    std::ofstream out(argv[2]);
    for (uint32_t w : tis::assemble(src))
        out << std::hex << std::setw(6) << std::setfill('0') << w << "\n";
    return 0;
}
