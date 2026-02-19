def describe(value: any) -> str {
    match value {
        case 0:
            return "zero";
        case 1 | 2 | 3:
            return "small number";
        case _:
            return "something else";
    }
}

with entry {
    print(describe(0));
    print(describe(2));
    print(describe(99));
}
