def categorize(fruit: str) -> str {
    switch fruit {
        case "apple":
            return "pome";
        case "banana" | "plantain":
            return "berry";
        default:
            return "unknown";
    }
}

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
    print(categorize("apple"));     # pome
    print(categorize("banana"));    # berry
    print(categorize("mango"));     # unknown
    print(describe(0));             # zero
    print(describe(2));             # small number
    print(describe(99));            # something else
}
