node Task {
    has id: str,
        title: str,
        done: bool = False;
}

edge Scheduled {
    has time: str,
        priority: int = 1;
}

with entry {
    root +>: Scheduled(time="9:00am", priority=3) :+> Task(id="1", title="Morning run");
    root +>: Scheduled(time="10:00am", priority=1) :+> Task(id="2", title="Read a book");

    # Get only nodes connected via Scheduled edges
    scheduled_tasks = [root->:Scheduled:->](?:Task);
    for t in scheduled_tasks {
        print(f"Scheduled: {t.title}");
    }

    # Filter edges by attribute value
    urgent = [root->:Scheduled:priority>=3:->](?:Task);
    for t in urgent {
        print(f"Urgent: {t.title}");
    }
}
