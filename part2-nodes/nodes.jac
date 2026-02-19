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

    # Query the graph
    tasks = [root-->](?:Task);
    for task in tasks {
        status = "done" if task.done else "pending";
        print(f"[{status}] {task.title}");
    }

    # Delete a task
    for task in [root-->](?:Task) {
        if task.id == "2" {
            del task;
        }
    }

    print("\nAfter deleting task 2:");
    for task in [root-->](?:Task) {
        print(f"  {task.title}");
    }
}
