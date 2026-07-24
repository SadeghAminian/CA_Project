#include "assembler.hpp"
#include <cassert>
#include <iostream>

using namespace tis;

uint32_t enc(const std::string& op, uint32_t dst = 0, uint8_t st = 0, uint32_t sv = 0) {
    return (static_cast<uint32_t>(OPCODE.at(op)) << 20) | (dst << 16) |
           (static_cast<uint32_t>(st) << 12) | (sv & 0xFFF);
}

void test_sum_ports() {
    auto r = assemble("MOV LEFT, ACC\nADD RIGHT\nMOV ACC, DOWN");
    assert(r[0] == enc("MOV", OPERAND.at("ACC"),  OPERAND.at("LEFT")));
    assert(r[1] == enc("ADD", 0,                  OPERAND.at("RIGHT")));
    assert(r[2] == enc("MOV", OPERAND.at("DOWN"), OPERAND.at("ACC")));
}

void test_label_jump() {
    auto r = assemble("LOOP:\nMOV LEFT, ACC\nJMP LOOP");
    assert(r[1] == enc("JMP", 0, LABEL_TYPE, 0));
}

void test_immediate() {
    auto r = assemble("ADD 5");
    assert(r[0] == enc("ADD", 0, IMM, 5));
}

void test_neg() {
    auto r = assemble("NEG");
    assert(r[0] == enc("NEG"));
}

int main() {
    test_sum_ports();  std::cout << "test_sum_ports PASSED\n";
    test_label_jump(); std::cout << "test_label_jump PASSED\n";
    test_immediate();  std::cout << "test_immediate PASSED\n";
    test_neg();        std::cout << "test_neg PASSED\n";
    return 0;
}
