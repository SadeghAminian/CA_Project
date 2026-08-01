#pragma once
#include <cstdint>
#include <string>
#include <unordered_map>
#include <unordered_set>

namespace tis {

inline const std::unordered_map<std::string, uint8_t> OPCODE = {
    {"NOP", 0x0}, {"MOV", 0x1}, {"SWP", 0x2}, {"SAV", 0x3},
    {"ADD", 0x4}, {"SUB", 0x5}, {"NEG", 0x6}, {"JMP", 0x7},
    {"JEZ", 0x8}, {"JNZ", 0x9}, {"JGZ", 0xA}, {"JLZ", 0xB}, {"JRO", 0xC}
};

inline const std::unordered_map<std::string, uint8_t> OPERAND = {
    {"ACC", 0x0}, {"NIL", 0x1}, {"LEFT", 0x2}, {"RIGHT", 0x3},
    {"UP", 0x4}, {"DOWN", 0x5}, {"ANY", 0x6}, {"LAST", 0x7}
};

constexpr uint8_t IMM        = 0x8;
constexpr uint8_t LABEL_TYPE = 0x8;

inline const std::unordered_set<std::string> ONE_OP  = {"NOP", "SWP", "SAV", "NEG"};
inline const std::unordered_set<std::string> TWO_OP  = {"MOV"};
inline const std::unordered_set<std::string> ONE_SRC = {"ADD", "SUB", "JRO"};
inline const std::unordered_set<std::string> JUMP    = {"JMP", "JEZ", "JNZ", "JGZ", "JLZ"};

}
