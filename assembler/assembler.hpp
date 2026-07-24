#pragma once
#include "encode.hpp"
#include <sstream>
#include <algorithm>
#include <cctype>

namespace tis {

inline std::string upper(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return std::toupper(c); });
    return s;
}

inline std::vector<std::vector<std::string>> tokenize(const std::string& source, Labels& labels) {
    std::vector<std::vector<std::string>> program;
    std::istringstream lines(source);
    std::string line;

    while (std::getline(lines, line)) {
        std::vector<std::string> tokens;
        std::string tok;
        for (char c : line) {
            if (c == ',' || std::isspace(static_cast<unsigned char>(c))) {
                if (!tok.empty()) { tokens.push_back(upper(tok)); tok.clear(); }
            } else {
                tok += c;
            }
        }
        if (!tok.empty()) tokens.push_back(upper(tok));
        if (tokens.empty()) continue;

        if (tokens.front().back() == ':') {
            std::string name = tokens.front();
            name.pop_back();
            labels[name] = static_cast<uint32_t>(program.size());
            tokens.erase(tokens.begin());
            if (tokens.empty()) continue;
        }
        program.push_back(std::move(tokens));
    }
    return program;
}

inline std::vector<uint32_t> assemble(const std::string& source) {
    Labels labels;
    auto program = tokenize(source, labels);
    std::vector<uint32_t> machine;
    machine.reserve(program.size());
    for (const auto& t : program)
        machine.push_back(encode(t, labels));
    return machine;
}

}
