import from uuid { uuid4 }
cl import "./styles.css";

node Task {
    has id: str,
        title: str,
        done: bool = False;
}

"""Add a task and return it."""
def:pub add_task(title: str) -> dict {
    task = root ++> Task(id=str(uuid4()), title=title);
    return {"id": task[0].id, "title": task[0].title, "done": task[0].done};
}

"""Get all tasks."""
def:pub get_tasks -> list {
    return [{"id": t.id, "title": t.title, "done": t.done} for t in [root-->](?:Task)];
}

"""Toggle a task's done status."""
def:pub toggle_task(id: str) -> dict {
    for task in [root-->](?:Task) {
        if task.id == id {
            task.done = not task.done;
            return {"id": task.id, "title": task.title, "done": task.done};
        }
    }
    return {};
}

"""Delete a task."""
def:pub delete_task(id: str) -> dict {
    for task in [root-->](?:Task) {
        if task.id == id {
            del task;
            return {"deleted": id};
        }
    }
    return {};
}

cl def:pub app -> JsxElement {
    has tasks: list = [],
        task_text: str = "";

    async can with entry {
        tasks = await get_tasks();
    }

    async def add_new_task -> None {
        if task_text.strip() {
            task = await add_task(task_text.strip());
            tasks = tasks.concat([task]);
            task_text = "";
        }
    }

    async def toggle(id: str) -> None {
        await toggle_task(id);
        tasks = tasks.map(
            lambda t: any -> any {
                return {"id": t.id, "title": t.title, "done": not t.done}
                if t.id == id else t;
            }
        );
    }

    async def remove(id: str) -> None {
        await delete_task(id);
        tasks = tasks.filter(lambda t: any -> bool { return t.id != id; });
    }

    remaining = len(tasks.filter(lambda t: any -> bool { return not t.done; }));

    return
        <div class="container">
            <h1>Day Planner</h1>
            <div class="input-row">
                <input
                    class="input"
                    value={task_text}
                    onChange={lambda e: any -> None { task_text = e.target.value; }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { add_new_task(); }
                    }}
                    placeholder="What needs to be done today?"
                />
                <button class="btn-add" onClick={add_new_task}>Add</button>
            </div>
            {[
                <div key={t.id} class="task-item">
                    <input
                        type="checkbox"
                        checked={t.done}
                        onChange={lambda -> None { toggle(t.id); }}
                    />
                    <span class={"task-title " + ("task-done" if t.done else "")}>
                        {t.title}
                    </span>
                    <button
                        class="btn-delete"
                        onClick={lambda -> None { remove(t.id); }}
                    >
                        X
                    </button>
                </div> for t in tasks
            ]}
            <div class="count">{remaining} tasks remaining</div>
        </div>;
}
