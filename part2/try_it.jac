node Task {
    has id: str,
        title: str,
        done: bool = False;
}

with entry {
    # Create three tasks
    root ++> Task(id="1", title="Buy groceries");
    root ++> Task(id="2", title="Team standup");
    root ++> Task(id="3", title="Go running");

    # Mark one as done
    for task in [root-->](?:Task) {
        if task.id == "2" {
            task.done = True;
        }
    }

    # List only pending tasks
    pending = [root-->](?:Task, done == False);
    print("Pending tasks:");
    for t in pending {
        print(f"  - {t.title}");
    }
}
