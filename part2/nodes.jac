node Task {
    has id: str,
        title: str,
        done: bool = False;
}

with entry {
    # Create tasks and connect them to root
    root ++> Task(id="1", title="Buy groceries");
    root ++> Task(id="2", title="Team standup at 10am");
    root ++> Task(id="3", title="Go for a run");

    print("Created 3 tasks!");
}
