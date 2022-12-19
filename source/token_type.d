module token_type;

enum TokenType
{
    minus,
    minusOne,
    plus,
    one,
    zero,
    rightShift,
    leftShift,
    allocate,
    deallocate,
    deallocateAll,
    accessValue,
    asChar,
    accessIA, // internal address
    accessValueIA, // by internal address
    print,
    input,
    and,
    or,
    xor,
    not,
    assign,
    equals,
    greaterOrEqual,
    lowerOrEqual,
    jumpIfTrue,
    jump,
    createLabel,

    endOfBlock,
    endOfLine,
    endOfFile,
}
