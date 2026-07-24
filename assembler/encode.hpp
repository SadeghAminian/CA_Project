#pragma once
#include "isa.hpp"
#include <vector>
#include <utility>
#include <stdexcept>

namespace tis {

using Labels = std::unordered_map<std::string, uint32_t>;

inline std::pair<uint8_t, uint32_t> src_field(const std::string& tok, const Labels& labels) {
    auto op = OPERAND.find(tok);
    if (op != OPERAND.end()) return {op->second, 0};
    auto lb = labels.find(tok);
    if (lb != labels.end()) return {LABEL_TYPE, lb->second};
    long v = std::stol(tok);
    return {IMM, static_cast<uint32_t>(v) & 0xFFF};
}

inline uint32_t encode(const std::vector<std::string>& t, const Labels& labels) {
    const std::string& mn = t[0];
    uint32_t op = OPCODE.at(mn);

    if (ONE_OP.count(mn))
        return op << 20;

    if (TWO_OP.count(mn)) {
        auto [st, sv] = src_field(t[1], labels);
        uint32_t dst = OPERAND.at(t[2]);
        return (op << 20) | (dst << 16) | (static_cast<uint32_t>(st) << 12) | sv;
    }

    if (ONE_SRC.count(mn) || JUMP.count(mn)) {
        auto [st, sv] = src_field(t[1], labels);
        return (op << 20) | (static_cast<uint32_t>(st) << 12) | sv;
    }

    throw std::runtime_error("Unknown mnemonic: " + mn);
}

}
