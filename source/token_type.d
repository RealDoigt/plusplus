module token_type;

enum TokenType
{
    Minus,
    MinusOne,
    Plus,
    One,
    Zero,
    RightShift,
    LeftShift,
    Allocate,
    Deallocate,
    DeallocateAll,
    AccessValue,
    AsChar,
    AccessIA, // internal address
    AccessValueIA, // by internal address
    Print,
    Input,
    And,
    Or,
    Xor,
    Not,
    Assign,
    Equals,
    GreaterOrEqual,
    LowerOrEqual,
    JumpIfTrue,
    Jump,
    CreateLabel,

    endOfLine
}
