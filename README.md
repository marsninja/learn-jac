# Build an AI Day Planner with Jac

By the end of this tutorial, you'll have built a full-stack AI day planner -- a single application that lets you manage daily tasks (auto-categorized by AI) and generate meal shopping lists from natural language descriptions. Along the way, you'll learn every major feature of the Jac programming language.

**Prerequisites:** [Installation](../../quick-guide/install.md) complete, [Hello World](../../quick-guide/hello-world.md) done.

The tutorial is split into seven parts. Each builds on the last:

| Part | What You'll Build | Key Concepts |
|------|-------------------|--------------|
| [1](#part-1-your-first-lines-of-jac) | [Hello World](#part-1-your-first-lines-of-jac) | Syntax basics, types, functions |
| [2](#part-2-modeling-data-with-nodes) | [Task data model](#part-2-modeling-data-with-nodes) | Nodes, graphs, root, edges |
| [3](#part-3-building-the-backend-api) | [Backend API](#part-3-building-the-backend-api) | `def:pub`, imports, enums, collections |
| [4](#part-4-a-reactive-frontend) | [Working frontend](#part-4-a-reactive-frontend) | Client-side code, JSX, reactive state |
| [5](#part-5-making-it-smart-with-ai) | [AI features](#part-5-making-it-smart-with-ai) | `by llm()`, `obj`, `sem`, structured output |
| [6](#part-6-authentication-and-multi-file-organization) | [Authentication](#part-6-authentication-and-multi-file-organization) | Login, signup, per-user data, multi-file |
| [7](#part-7-object-spatial-programming-with-walkers) | [Walkers & OSP](#part-7-object-spatial-programming-with-walkers) | Walkers, abilities, graph traversal |

Each part has a corresponding directory with runnable source files:

```
learn-jac/
├── part1-basics/          # hello.jac, vars.jac, funcs.jac, control.jac, match.jac
├── part2-nodes/           # nodes.jac, edges.jac
├── part3-4-day-planner/   # main.jac, styles.css
├── part5-ai/              # main.jac, styles.css
├── part6-auth/            # main.jac, frontend.cl.jac, frontend.impl.jac, styles.css
└── part7-walkers/         # main.jac, frontend.cl.jac, frontend.impl.jac, styles.css
```

---

## Part 1: Your First Lines of Jac

Jac is a programming language that compiles to Python. If you know Python, Jac will feel familiar -- but with curly braces instead of indentation, semicolons at the end of statements, and built-in support for graphs, AI, and full-stack web apps. This section covers the fundamentals.

**Hello, World**

Create a file called `hello.jac` ([source](part1-basics/hello.jac)):

```jac
with entry {
    print("Hello, World!");
}
```

Run it:

```bash
jac run hello.jac
```

`with entry { }` is Jac's program entry point -- equivalent to Python's `if __name__ == "__main__"`. Everything inside runs when the file executes.

**Variables and Types**

Jac has four basic scalar types: `str`, `int`, `float`, and `bool`. Type annotations are required when declaring variables with explicit types ([source](part1-basics/vars.jac)):

```jac
with entry {
    name: str = "My Day Planner";
    version: int = 1;
    rating: float = 4.5;
    ready: bool = True;

    # Type can be inferred from the value
    greeting = f"Welcome to {name} v{version}!";
    print(greeting);
}
```

Jac supports **f-strings** for string interpolation (just like Python), **comments** with `#`, and **block comments** with `#* ... *#`:

```jac
# This is a line comment

#* This is a
   block comment *#
```

**Functions**

Functions use the `def` keyword. Both parameters and return values need type annotations ([source](part1-basics/funcs.jac)):

```jac
def greet(name: str) -> str {
    return f"Good morning, {name}! Let's plan your day.";
}

def add(a: int, b: int) -> int {
    return a + b;
}

with entry {
    print(greet("Alice"));
    print(add(2, 3));  # 5
}
```

Functions that don't return a value use `-> None` (or you can omit the return type annotation entirely).

**Control Flow**

Jac uses curly braces `{}` for all blocks -- no significant indentation ([source](part1-basics/control.jac)):

```jac
def check_time(hour: int) -> str {
    if hour < 12 {
        return "Good morning!";
    } elif hour < 17 {
        return "Good afternoon!";
    } else {
        return "Good evening!";
    }
}

with entry {
    # For loop over a list
    tasks = ["Buy groceries", "Team standup", "Go running"];
    for task in tasks {
        print(f"- {task}");
    }

    # Range-based loop
    for i in range(5) {
        print(i);  # 0, 1, 2, 3, 4
    }

    # While loop
    count = 3;
    while count > 0 {
        print(f"Countdown: {count}");
        count -= 1;
    }

    # Ternary expression
    hour = 10;
    mood = "energized" if hour < 12 else "tired";
    print(mood);
}
```

Jac also supports **`match`/`case`** for pattern matching ([source](part1-basics/match.jac)):

```jac
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
```

**What You Learned**

- **`with entry { }`** -- program entry point
- **Types**: `str`, `int`, `float`, `bool`
- **`def`** -- function declaration with typed parameters and return types
- **Control flow**: `if` / `elif` / `else`, `for`, `while`, `match` -- all with braces
- **`#`** -- line comments (`#* block comments *#`)
- **f-strings** -- string interpolation with `f"...{expr}..."`
- **Ternary** -- `value if condition else other`

---

## Part 2: Modeling Data with Nodes

Most languages store data in variables, objects, or database rows. Jac adds a powerful alternative: **nodes** that live in a **graph**. Nodes persist automatically -- no database setup, no ORM, no SQL.

**What is a Node?**

A node is a data type declared with the `node` keyword. Its fields are declared with `has`:

```jac
node Task {
    has id: str,
        title: str,
        done: bool = False;
}
```

This looks similar to a class, but nodes have a superpower: they can be connected to other nodes with **edges**, forming a graph. When connected to the global `root` node, they persist across server restarts -- no database needed.

**The Root Node and the Graph**

Every Jac program has a built-in `root` node -- the entry point of the graph. Think of it as the top of a tree:

```
root  (starts empty)
```

You add data by creating nodes and connecting them with edges.

**Creating and Connecting Nodes**

The `++>` operator creates a node and connects it to an existing node with an edge. See the complete example in [`part2-nodes/nodes.jac`](part2-nodes/nodes.jac):

```jac
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
```

Run it with `jac run hello.jac`. Your graph now looks like:

```
root ---> Task("Buy groceries")
  |-----> Task("Team standup at 10am")
  |-----> Task("Go for a run")
```

The `++>` operator returns a list containing the newly created node. You can capture it:

```jac
result = root ++> Task(id="1", title="Buy groceries");
task = result[0];  # The new Task node
print(task.title);  # "Buy groceries"
```

**Querying the Graph**

To read nodes from the graph, use the `[-->]` syntax:

```jac
with entry {
    root ++> Task(id="1", title="Buy groceries");
    root ++> Task(id="2", title="Team standup at 10am");

    # Get ALL nodes connected from root
    everything = [root-->];

    # Filter by node type with (?:Type)
    tasks = [root-->](?:Task);
    for task in tasks {
        status = "done" if task.done else "pending";
        print(f"[{status}] {task.title}");
    }
}
```

`[root-->]` reads as "all nodes connected *from* root." The `(?:Task)` filter keeps only nodes of type `Task`. This is a **graph query** -- Jac's built-in way to traverse data without writing database queries.

Other directions work too:

- `[node-->]` -- outgoing connections (forward)
- `[node<--]` -- incoming connections (backward)
- `[node<-->]` -- both directions

**Deleting Nodes**

Use `del` to remove a node from the graph:

```jac
for task in [root-->](?:Task) {
    if task.id == "2" {
        del task;
    }
}
```

**Custom Edges**

So far, the edges between nodes are generic -- they just mean "connected." Jac lets you create **typed edges** with their own data. See the complete example in [`part2-nodes/edges.jac`](part2-nodes/edges.jac):

```jac
edge Scheduled {
    has time: str,
        priority: int = 1;
}
```

Connect nodes with a typed edge using `+>: EdgeType :+>`:

```jac
root +>: Scheduled(time="9:00am", priority=3) :+> Task(id="1", title="Morning run");
```

You can then filter queries by edge type:

```jac
# Get only nodes connected via Scheduled edges
scheduled_tasks = [root->:Scheduled:->](?:Task);

# Filter edges by attribute value
urgent = [root->:Scheduled:priority>=3:->](?:Task);
```

We won't use custom edges in the main app (default edges are sufficient for our use case), but they're powerful for modeling complex relationships -- social networks, org charts, dependency graphs, and more.

**What You Learned**

- **`node`** -- a persistent data type that lives in the graph
- **`has`** -- declares fields with types and optional defaults
- **`root`** -- the built-in entry point of the graph
- **`++>`** -- create a node and connect it with an edge
- **`[root-->]`** -- query all connected nodes
- **`(?:Type)`** -- filter query results by node type
- **`del`** -- remove a node from the graph
- **`edge`** -- define a typed edge with its own data
- **`+>: EdgeType :+>`** -- connect with a typed edge
- **`[root->:EdgeType:->]`** -- filter by edge type

---

## Part 3: Building the Backend API

Time to build a real backend. You'll create HTTP endpoints that manage tasks -- without a web framework, route decorators, or serializers.

**Create the Project**

```bash
jac create day-planner --use client --skip
cd day-planner
```

`--skip` skips interactive prompts. You don't need to run `jac install` separately -- `jac start` handles dependency installation automatically.

You can delete the scaffolded `main.jac` -- you'll replace it with the code below. Also create a `styles.css` file in the project root (we'll fill it in Part 4).

**Imports**

Jac can import any Python package. We need `uuid` for generating unique IDs:

```jac
import from uuid { uuid4 }
```

The syntax is `import from module { names }` -- it imports `uuid4` from Python's standard library `uuid` module. You can import anything from PyPI the same way.

**def:pub -- Functions as Endpoints**

Mark a function `def:pub` and Jac automatically generates an HTTP endpoint for it:

```jac
"""Add a task and return it."""
def:pub add_task(title: str) -> dict {
    task = root ++> Task(id=str(uuid4()), title=title);
    return {"id": task[0].id, "title": task[0].title, "done": task[0].done};
}
```

That single function is now:

- A server-side function you can call from Jac code
- An HTTP endpoint that clients can call over the network
- Auto-documented with the docstring

No route configuration, no controllers, no request parsing. The function **is** the API.

**Docstrings** in Jac come *before* the declaration (unlike Python where they go inside the function body). They're enclosed in triple quotes `"""..."""`.

**Building the CRUD Endpoints**

Here are all four operations for managing tasks. See the complete file at [`part3-4-day-planner/main.jac`](part3-4-day-planner/main.jac):

```jac
import from uuid { uuid4 }

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
```

Let's look at the new patterns used here.

**Collections**

**Lists** work like Python -- create with `[]`, access by index, iterate with `for`:

```jac
tasks = ["Buy groceries", "Go running", "Read a book"];
first = tasks[0];          # "Buy groceries"
last = tasks[-1];          # "Read a book"
length = len(tasks);       # 3
tasks.append("Cook dinner");
```

**Dictionaries** use `{"key": value}` syntax:

```jac
task_data = {"id": "1", "title": "Buy groceries", "done": False};
print(task_data["title"]);  # "Buy groceries"
task_data["done"] = True;   # Update a value
```

**List comprehensions** build lists in a single expression:

```jac
# Build a list of dicts from all Task nodes
[{"id": t.id, "title": t.title} for t in [root-->](?:Task)]

# With a filter condition
[t.title for t in [root-->](?:Task) if not t.done]
```

**Lambdas**

Lambdas are anonymous functions. They're essential for the frontend (Part 4), so let's introduce them now:

```jac
# Lambda with typed parameters
double = lambda x: int -> int { return x * 2; };

# Lambda used inline with list operations
numbers = [1, 2, 3, 4, 5];
evens = list(filter(lambda x: int -> bool { return x % 2 == 0; }, numbers));

# Lambda with no parameters
say_hi = lambda -> str { return "hi"; };
```

The syntax is `lambda params -> return_type { body }`. You'll see these heavily in event handlers.

**Enums**

An **enum** constrains a value to a fixed set of options:

```jac
enum Priority { LOW, MEDIUM, HIGH, URGENT }
```

Access values with `Priority.HIGH` and convert to string with `str(Priority.HIGH)`. We'll use enums extensively in Part 5 for constraining AI output.

**Global Variables**

The `glob` keyword declares a module-level variable:

```jac
glob app_name = "Day Planner";
glob max_tasks = 100;
```

We'll use `glob` in Part 5 to initialize the AI model.

**Run It**

You can start the server now -- the `def:pub` functions are live HTTP endpoints even without a frontend:

```bash
jac start main.jac
```

The server starts on port 8000 by default. Use `--port 3000` to pick a different port.

!!! warning "Common issue"
    If you see "Address already in use", another process is on that port. Use `--port` to pick a different one, or see [Troubleshooting](../troubleshooting.md#server-wont-start-address-already-in-use).

**What You Learned**

- **`def:pub`** -- functions that auto-become HTTP endpoints
- **`import from module { name }`** -- import Python (or any) packages
- **`"""..."""`** -- docstrings (placed before the declaration)
- **List comprehensions** -- `[expr for x in list]` and `[expr for x in list if cond]`
- **Dictionaries** -- `{"key": value}` for structured data
- **`lambda`** -- anonymous functions: `lambda params -> type { body }`
- **`enum`** -- fixed set of named values
- **`glob`** -- global/module-level variables
- **`jac start`** -- run the web server

---

## Part 4: A Reactive Frontend

Jac isn't just a backend language. It can render full UIs in the browser using JSX syntax -- similar to React, but without the JavaScript toolchain.

**The cl Prefix**

Code prefixed with `cl` runs in the **browser**, not on the server:

```jac
cl import "./styles.css";
```

This loads a CSS file client-side. Add this line at the top of your `main.jac`, after the `uuid` import.

**Building the Component**

A `cl def:pub` function returning `JsxElement` is a UI component:

```jac
cl def:pub app -> JsxElement {
    has tasks: list = [],
        task_text: str = "";

    # ... methods and render tree ...
}
```

**`has`** inside a component declares **reactive state**. When `tasks` or `task_text` changes, the UI automatically re-renders -- same idea as React's `useState`, but declared as simple properties.

**Lifecycle Hooks**

**`can with entry`** runs when the component first mounts (like React's `useEffect` on mount):

```jac
    async can with entry {
        tasks = await get_tasks();
    }
```

This fetches all tasks from the server when the page loads.

**Event Handlers**

Lambdas handle user events inline:

```jac
<input
    value={task_text}
    onChange={lambda e: any -> None { task_text = e.target.value; }}
    onKeyPress={lambda e: any -> None {
        if e.key == "Enter" { add_new_task(); }
    }}
/>
```

Updating `task_text` triggers a re-render because it's reactive state (declared with `has`).

**Transparent Server Calls**

Here's the key insight: **`await add_task(text)`** calls the server function as if it were local. Because `add_task` is `def:pub`, Jac generated an HTTP endpoint on the server and a matching client stub automatically. You never write fetch calls, parse JSON, or handle HTTP status codes.

```jac
    async def add_new_task -> None {
        if task_text.strip() {
            task = await add_task(task_text.strip());
            tasks = tasks.concat([task]);
            task_text = "";
        }
    }
```

**Rendering Lists and Conditionals**

**`{[... for t in tasks]}`** renders a list of elements. Each item needs a unique `key` prop:

```jac
{[
    <div key={t.id} class="task-item">
        <span>{t.title}</span>
    </div> for t in tasks
]}
```

**Conditional rendering** uses Jac's ternary expression inside JSX:

```jac
<span class={"task-title " + ("task-done" if t.done else "")}>
    {t.title}
</span>
```

**The Complete Frontend**

Add `cl import "./styles.css";` after your existing import, then add the frontend component at the bottom of `main.jac`. See the complete file: [`part3-4-day-planner/main.jac`](part3-4-day-planner/main.jac)

A few things to notice in the component:

- **`tasks.map(lambda ...)`** transforms each item in the list (like JavaScript's `.map()`)
- **`tasks.filter(lambda ...)`** keeps only matching items
- **`tasks.concat([task])`** creates a new list with the item appended
- **`async`** marks methods that call the server (since network calls are asynchronous)

**Add Styles**

Fill in `styles.css` in your project root. See: [`part3-4-day-planner/styles.css`](part3-4-day-planner/styles.css)

**Run It**

```bash
jac start main.jac
```

Open [http://localhost:8000](http://localhost:8000). You should see a clean day planner with an input field and an "Add" button. Try it:

1. Type "Buy groceries" and press Enter -- the task appears
2. Click the checkbox -- it gets crossed out
3. Click X -- it disappears
4. Stop the server and restart it -- your tasks are still there

That last point is important. The data persisted because nodes live in the graph database, not in memory.

**What You Learned**

- **`cl`** -- prefix for client-side (browser) code
- **`cl import`** -- load CSS (or npm packages) in the browser
- **`cl def:pub app -> JsxElement`** -- the main UI component
- **`has`** (in components) -- reactive state that triggers re-renders on change
- **`can with entry`** -- lifecycle hook that runs on component mount
- **`await func()`** -- transparent server calls from the client (no HTTP code)
- **`async`** -- marks functions that perform asynchronous operations
- **JSX syntax** -- `{expression}`, `{[... for x in list]}`, event handlers with lambdas
- **`.map()`, `.filter()`, `.concat()`** -- list operations for immutable state updates

---

## Part 5: Making It Smart with AI

Your day planner works, but it's not smart. Let's add two AI features: **automatic task categorization** and a **meal shopping list generator**. Both take surprisingly little code.

!!! tip "Starting fresh"
    If you have leftover data from Parts 1–4, delete the `.jac/data/` directory before running Part 5. The schema changes (adding `category` to Task) may conflict with old nodes.

**Set Up Your API Key**

Jac's AI features use an LLM under the hood. You need an API key from Anthropic (or another provider). Set it as an environment variable:

```bash
export ANTHROPIC_API_KEY="your-key-here"
```

!!! info "Free and Alternative Models"
    **Anthropic API keys are not free** -- you'll need API credits at [console.anthropic.com](https://console.anthropic.com).

    **Free alternative:** Use Google Gemini with [Gemini API](https://ai.google.dev/):
    ```jac
    glob llm = Model(model_name="gemini/gemini-2.5-flash");
    ```

    **Self-hosted:** Run models locally with [Ollama](https://ollama.ai/):
    ```jac
    glob llm = Model(model_name="ollama/llama3.2:1b");
    ```

    Jac's AI plugin wraps [LiteLLM](https://docs.litellm.ai/docs/providers), supporting OpenAI, Anthropic, Google, Azure, and many more.

**Configure the LLM**

Add the AI import and model initialization to the top of `main.jac`, right after the existing imports:

```jac
import from uuid { uuid4 }
import from byllm.lib { Model }
cl import "./styles.css";

glob llm = Model(model_name="claude-sonnet-4-20250514");
```

`import from byllm.lib { Model }` loads Jac's AI plugin. `glob llm = Model(...)` initializes the model at module level -- `glob` declares a global variable, as we learned in Part 3.

**Enums as Output Constraints**

```jac
enum Category { WORK, PERSONAL, SHOPPING, HEALTH, FITNESS, OTHER }
```

This enum constrains the AI to return *exactly one* of these values. Without it, the LLM might return "shopping", "Shopping", "groceries", or "grocery shopping" -- all meaning the same thing. The enum eliminates that ambiguity.

**by llm() -- AI Function Delegation**

Here's the key feature:

```jac
"""Categorize a task based on its title."""
def categorize(title: str) -> Category by llm();
```

That's the **entire function**. There's no body -- `by llm()` tells Jac to have the LLM generate the return value. The compiler extracts meaning from:

- The **function name** -- `categorize` tells the LLM what to do
- The **parameter names and types** -- `title: str` is what the LLM receives
- The **return type** -- `Category` constrains output to one of the enum values
- The **docstring** -- additional context for the LLM

The function name, parameter names, types, and docstring **are the specification**. The LLM fulfills it.

**Wire It Into the Task Flow**

Two changes. First, add a `category` field to the `Task` node:

```jac
node Task {
    has id: str,
        title: str,
        done: bool = False,
        category: str = "other";
}
```

Then update `add_task` to call the AI:

```jac
"""Add a task with AI categorization."""
def:pub add_task(title: str) -> dict {
    category = str(categorize(title)).split(".")[-1].lower();
    task = root ++> Task(id=str(uuid4()), title=title, category=category);
    return {
        "id": task[0].id, "title": task[0].title,
        "done": task[0].done, "category": task[0].category
    };
}
```

`str(categorize(title)).split(".")[-1].lower()` converts `Category.SHOPPING` to `"shopping"` for clean display.

Also update `get_tasks` and `toggle_task` to include `"category"` in their return dictionaries:

```jac
"""Get all tasks."""
def:pub get_tasks -> list {
    return [
        {"id": t.id, "title": t.title, "done": t.done, "category": t.category}
        for t in [root-->](?:Task)
    ];
}

"""Toggle a task's done status."""
def:pub toggle_task(id: str) -> dict {
    for task in [root-->](?:Task) {
        if task.id == id {
            task.done = not task.done;
            return {
                "id": task.id, "title": task.title,
                "done": task.done, "category": task.category
            };
        }
    }
    return {};
}
```

`delete_task` doesn't need changes -- it doesn't return task data.

**Structured Output with obj and sem**

Now for the shopping list. We need the AI to return *structured* data -- not just a string, but a list of ingredients with quantities, units, and costs.

**`obj`** defines a structured data type. Unlike `node`, objects aren't stored in the graph -- they're just data containers:

```jac
enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}
```

**`sem`** adds a semantic hint that tells the LLM what an ambiguous field means:

```jac
sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";
```

Without `sem`, `cost: float` is ambiguous (cost in what currency? per unit or total?). With the hint, the LLM knows exactly what to generate.

Now the AI function:

```jac
"""Generate a shopping list of ingredients needed for a described meal."""
def generate_shopping_list(meal_description: str) -> list[Ingredient] by llm();
```

The LLM returns a `list[Ingredient]` -- a list of typed objects, each with name, quantity, unit, cost, and carb flag. Jac validates the structure automatically.

**Shopping List Nodes and Endpoints**

Add a node for persisting generated ingredients:

```jac
node ShoppingItem {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}
```

And three new endpoints:

```jac
"""Generate a shopping list from a meal description."""
def:pub generate_list(meal: str) -> list {
    # Clear old items
    for item in [root-->](?:ShoppingItem) {
        del item;
    }
    # Generate new ones
    ingredients = generate_shopping_list(meal);
    result: list = [];
    for ing in ingredients {
        data = {
            "name": ing.name,
            "quantity": ing.quantity,
            "unit": str(ing.unit).split(".")[-1].lower(),
            "cost": ing.cost,
            "carby": ing.carby
        };
        root ++> ShoppingItem(
            name=data["name"], quantity=data["quantity"],
            unit=data["unit"], cost=data["cost"], carby=data["carby"]
        );
        result.append(data);
    }
    return result;
}

"""Get the current shopping list."""
def:pub get_shopping_list -> list {
    return [
        {"name": s.name, "quantity": s.quantity, "unit": s.unit,
         "cost": s.cost, "carby": s.carby}
        for s in [root-->](?:ShoppingItem)
    ];
}

"""Clear the shopping list."""
def:pub clear_shopping_list -> dict {
    for item in [root-->](?:ShoppingItem) {
        del item;
    }
    return {"cleared": True};
}
```

Notice how `generate_list` clears old shopping items before generating new ones. The graph now holds both task and shopping data:

```
root ---> Task("Buy groceries", category="shopping")
  |-----> Task("Team standup", category="work")
  |-----> ShoppingItem("Chicken breast", 2lb, $5.99)
  |-----> ShoppingItem("Soy sauce", 2tbsp, $0.50)
```

**Update the Frontend**

The frontend needs a two-column layout: tasks on the left, shopping list on the right. Update the component with new state, methods, and the shopping panel. See the complete file: [`part5-ai/main.jac`](part5-ai/main.jac)

**Update Styles**

Replace `styles.css` with the expanded version that supports the two-column layout and shopping list. See: [`part5-ai/styles.css`](part5-ai/styles.css)

**Run It**

```bash
export ANTHROPIC_API_KEY="your-key"
jac start main.jac
```

!!! warning "Common issue"
    If adding a task silently fails (nothing happens), check the terminal running `jac start` for error messages -- a missing or invalid API key causes a server error.

Open [http://localhost:8000](http://localhost:8000). The app now has two columns. Try it:

1. **Add "Buy groceries"** -- it appears with a "shopping" badge
2. **Add "Schedule dentist appointment"** -- tagged "health"
3. **Add "Review pull requests"** -- tagged "work"
4. **Type "chicken stir fry for 4"** in the meal planner and click Generate -- a structured shopping list appears with quantities, units, costs, and carb flags
5. **Restart the server** -- everything persists (both tasks and shopping list)

The AI can only pick from the enum values you defined -- `Category` for tasks, `Unit` for ingredients. The type system constrains the LLM's output automatically.

**What You Learned**

- **`import from byllm.lib { Model }`** -- load the AI plugin
- **`glob llm = Model(...)`** -- initialize an LLM at module level
- **`enum`** -- constrain AI output to specific values
- **`def func(...) -> Type by llm()`** -- let the LLM implement a function from its signature
- **`obj`** -- structured data types (not stored in graph, used as data containers)
- **`sem Type.field = "..."`** -- semantic hints that guide LLM field interpretation
- **`-> list[Type] by llm()`** -- get validated structured output from the LLM
- **Jac's type system is the LLM's output schema** -- name things clearly and `by llm()` handles the rest

---

## Part 6: Authentication and Multi-File Organization

Your day planner has AI-powered task categorization and a shopping list generator, and everything persists in the graph. But right now there's no concept of users -- anyone who visits the app sees the same data. Let's add authentication and reorganize the growing codebase into multiple files.

**Built-in Auth**

Jac has built-in authentication functions for client-side code:

```jac
import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }
```

- **`jacSignup(username, password)`** -- create an account (returns `{"success": True/False}`)
- **`jacLogin(username, password)`** -- log in (returns `True` or `False`)
- **`jacLogout()`** -- log out
- **`jacIsLoggedIn()`** -- check login status

No JWT handling, no session management, no token storage -- it's all built in.

**Multi-File Organization**

As the app grows, putting everything in one file gets unwieldy. Jac supports splitting code across files with a **declaration/implementation pattern** that keeps UI and logic separate.

**`frontend.cl.jac`** -- state, method signatures, and the render tree:

```jac
def:pub app -> JsxElement {
    has tasks: list = [];

    async def fetchTasks -> None;  # Just the signature -- no body
    # ... more declarations ...

    # ... UI rendering ...
}
```

**`frontend.impl.jac`** -- method bodies in `impl` blocks:

```jac
impl app.fetchTasks -> None {
    tasksLoading = True;
    tasks = await get_tasks();
    tasksLoading = False;
}
```

The `.cl.jac` file focuses on what the component *looks like* and what state it has. The `.impl.jac` file focuses on what the methods *do*. It's optional -- you could keep everything in one file -- but it keeps things readable as the app grows.

**`cl { }` blocks** let you embed client-side code in a server file. This is useful for the entry point:

```jac
cl {
    import from frontend { app as ClientApp }

    def:pub app -> JsxElement {
        return
            <ClientApp />;
    }
}
```

Everything outside `cl { }` runs on the server. Everything inside runs in the browser.

**Dependency-Triggered Abilities**

A **dependency-triggered ability** re-runs whenever specific state changes -- like React's `useEffect` with a dependency array:

```jac
    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchTasks();
            fetchShoppingList();
        }
    }
```

When `isLoggedIn` changes from `False` to `True` (user logs in), this ability fires automatically and loads their data.

**The Complete Authenticated App**

Create a new project for the authenticated version:

```bash
jac create day-planner-auth --use client --skip
cd day-planner-auth
```

You'll create these files:

```
day-planner-auth/
├── main.jac                # Server: nodes, AI, endpoints, entry point
├── frontend.cl.jac         # Client: state, UI, method declarations
├── frontend.impl.jac       # Client: method implementations
└── styles.css              # Styles
```

**Run It**

The complete source files for this part:

- [`part6-auth/main.jac`](part6-auth/main.jac) -- server-side nodes, AI types, endpoints, and the `cl { }` entry point
- [`part6-auth/frontend.cl.jac`](part6-auth/frontend.cl.jac) -- client-side UI with auth forms, task list, and shopping list
- [`part6-auth/frontend.impl.jac`](part6-auth/frontend.impl.jac) -- method implementations for login, signup, CRUD, and shopping
- [`part6-auth/styles.css`](part6-auth/styles.css) -- full styles including auth form, two-column layout, and shopping list

```bash
export ANTHROPIC_API_KEY="your-key"
jac start main.jac
```

Open [http://localhost:8000](http://localhost:8000). You should see a login screen.

1. **Sign up** with any username and password
2. **Add tasks** -- they auto-categorize just like Part 5
3. **Try the meal planner** -- type "spaghetti bolognese for 4" and click Generate
4. **Refresh the page** -- your data persists (it's in the graph)
5. **Restart the server** -- all data is still there

Your day planner is now a **complete, fully functional application** -- authentication, AI-powered categorization, meal planning, graph persistence, and a clean multi-file architecture. All built with `def:pub` endpoints, nodes, and edges.

**What You Learned**

- **`jacSignup`**, **`jacLogin`**, **`jacLogout`**, **`jacIsLoggedIn`** -- built-in auth functions
- **`import from "@jac/runtime"`** -- import Jac's built-in client-side utilities
- **`can with [deps] entry`** -- dependency-triggered abilities (re-runs when state changes)
- **`cl { }`** -- embed client-side code in a server file
- **Declaration/implementation split** -- `.cl.jac` for UI, `.impl.jac` for logic
- **`impl app.method { ... }`** -- implement declared methods in a separate file

---

## Part 7: Object-Spatial Programming with Walkers

Your day planner is complete -- tasks persist in the graph, AI categorizes them, and you can generate shopping lists. Everything works using `def:pub` functions that directly manipulate graph nodes.

Now let's learn Jac's most distinctive feature: **Object-Spatial Programming (OSP)**. OSP introduces **walkers** -- mobile units of computation that *travel through* the graph -- and **abilities** -- logic that triggers automatically when a walker arrives at a node. It's a different way of thinking about code: instead of functions that reach into data, you have agents that move to data.

This section reimplements the day planner's backend using walkers to show how OSP works. The app behavior stays the same -- this is about learning an alternative (and powerful) programming paradigm.

**What is a Walker?**

A walker is code that moves through the graph, triggering abilities as it enters each node:

```
Walker: ListTasks
  |
  v
[root] ---> [Task: "Buy groceries"]     <- walker enters, ability fires
  |-------> [Task: "Team standup"]      <- walker enters, ability fires
  |-------> [Task: "Go running"]        <- walker enters, ability fires
```

Think of it like a robot walking through a building. At each room (node), it can look around (`here`), check its own clipboard (`self`), move to connected rooms (`visit`), and write down findings (`report`).

The core keywords:

- **`visit [-->]`** -- move the walker to all connected nodes
- **`here`** -- the node the walker is currently visiting
- **`self`** -- the walker itself (its own state and properties)
- **`report`** -- send data back to whoever spawned the walker
- **`disengage`** -- stop traversal immediately

**Functions vs Walkers: Side by Side**

Here's `add_task` as a `def:pub` function (what you already have):

```jac
def:pub add_task(title: str) -> dict {
    category = str(categorize(title)).split(".")[-1].lower();
    task = root ++> Task(id=str(uuid4()), title=title, category=category);
    return {"id": task[0].id, "title": task[0].title, "done": task[0].done, "category": task[0].category};
}
```

And here's the same logic as a walker:

```jac
walker AddTask {
    has title: str;

    can create with Root entry {
        category = str(categorize(self.title)).split(".")[-1].lower();
        new_task = here ++> Task(
            id=str(uuid4()),
            title=self.title,
            category=category
        );
        report {
            "id": new_task[0].id,
            "title": new_task[0].title,
            "done": new_task[0].done,
            "category": new_task[0].category
        };
    }
}
```

The differences:

- **`walker AddTask`** -- declares a walker (like a node, but mobile)
- **`has title: str`** -- data the walker carries with it (passed when spawning)
- **`can create with Root entry`** -- an **ability** that fires when the walker enters a `Root` node
- **`here`** -- the current node (what `root` was in the function version)
- **`self.title`** -- the walker's own properties (what `title` parameter was)
- **`report { ... }`** -- sends data back (what `return` was)

Spawn it:

```jac
result = root spawn AddTask(title="Buy groceries");
print(result.reports[0]);  # The reported dict
```

**`root spawn AddTask(title="...")`** creates a walker and starts it at root. Whatever the walker `report`s ends up in `result.reports`.

**The Accumulator Pattern**

The power of walkers becomes clearer with `ListTasks` -- collecting data across multiple nodes:

```jac
walker ListTasks {
    has results: list = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with Task entry {
        self.results.append({
            "id": here.id,
            "title": here.title,
            "done": here.done,
            "category": here.category
        });
    }

    can done with Root exit {
        report self.results;
    }
}
```

Three abilities work together:

1. **`with Root entry`** -- the walker enters root, `visit [-->]` sends it to all connected nodes
2. **`with Task entry`** -- fires at each Task node, appending data to `self.results`
3. **`with Root exit`** -- after visiting all children, the walker returns to root and reports the accumulated list

The walker's `has results: list = []` state **persists across the entire traversal** -- that's how it collects results from multiple nodes.

Compare this to the function version:

```jac
def:pub get_tasks -> list {
    return [{"id": t.id, "title": t.title, "done": t.done, "category": t.category}
            for t in [root-->](?:Task)];
}
```

The function is shorter for this simple case. But walkers shine when the graph is deeper -- imagine tasks containing subtasks containing notes. A walker naturally recurses through the whole structure with `visit [-->]` at each level.

!!! warning "Common issue"
    If walker reports come back empty, make sure you have `visit [-->]` to send the walker to connected nodes, and that the node type in `with X entry` matches your graph structure.

**Node Abilities**

So far, abilities have lived on the **walker** (e.g., `can collect with Task entry`). But abilities can also live on the **node** itself:

```jac
node Task {
    has id: str,
        title: str,
        done: bool = False,
        category: str = "other";

    can respond with ListTasks entry {
        visitor.results.append({
            "id": here.id,
            "title": here.title,
            "done": here.done,
            "category": here.category
        });
    }
}
```

When a `ListTasks` walker visits a `Task` node, the node's `respond` ability fires automatically. Inside a node ability, **`visitor`** refers to the visiting walker (so you can access `visitor.results`).

Both patterns work -- walker-side abilities and node-side abilities. Choose whichever reads more clearly for your use case. Walker-side abilities are great when the logic is about the traversal. Node-side abilities are great when the logic is about the node's data.

**visit and disengage**

**`visit [-->]`** queues all connected nodes for the walker to visit next. You can also filter:

```jac
visit [-->](?:Task);      # Visit only Task nodes
visit [-->] else {         # Fallback if no nodes to visit
    report "No tasks found";
};
```

**`disengage`** stops the walker immediately -- useful when you've found what you're looking for:

```jac
walker ToggleTask {
    has task_id: str;

    can search with Root entry { visit [-->]; }

    can toggle with Task entry {
        if here.id == self.task_id {
            here.done = not here.done;
            report {"id": here.id, "done": here.done};
            disengage;  # Found it -- stop visiting remaining nodes
        }
    }
}
```

Without `disengage`, the walker would continue visiting every remaining node unnecessarily.

`DeleteTask` follows the same pattern:

```jac
walker DeleteTask {
    has task_id: str;

    can search with Root entry { visit [-->]; }

    can remove with Task entry {
        if here.id == self.task_id {
            del here;
            report {"deleted": self.task_id};
            disengage;
        }
    }
}
```

**Multi-Step Traversals**

The `GenerateShoppingList` walker shows the real power of OSP -- doing two things in one traversal:

```jac
walker GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        # First, visit children to clear old ingredients
        visit [-->];
        # Then generate new ones (runs after visit completes)
        ingredients = generate_shopping_list(self.meal_description);
        result: list = [];
        for ing in ingredients {
            data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            here ++> ShoppingItem(
                name=data["name"], quantity=data["quantity"],
                unit=data["unit"], cost=data["cost"], carby=data["carby"]
            );
            result.append(data);
        }
        report result;
    }

    can clear_old with ShoppingItem entry {
        del here;
    }
}
```

When `visit [-->]` runs, the walker visits all connected nodes. If any are `ShoppingItem` nodes, the `clear_old` ability fires and deletes them. Then control returns to root, where the walker generates fresh ingredients via the LLM and persists them as new nodes.

Compare this to the function version where you needed an explicit loop to clear old items. The walker version expresses the same intent more declaratively: "when I encounter a ShoppingItem, delete it."

The remaining shopping walkers follow familiar patterns:

```jac
walker GetShoppingList {
    has items: list = [];

    can collect with Root entry { visit [-->]; }

    can gather with ShoppingItem entry {
        self.items.append({
            "name": here.name, "quantity": here.quantity,
            "unit": here.unit, "cost": here.cost, "carby": here.carby
        });
    }

    can done with Root exit { report self.items; }
}

walker ClearShoppingList {
    can collect with Root entry { visit [-->]; }

    can clear with ShoppingItem entry {
        del here;
        report {"cleared": True};
    }
}
```

**Spawning Walkers from the Frontend**

In the `def:pub` version, the frontend called server functions directly with `await add_task(title)`. With walkers, the frontend **spawns** them instead.

**`sv import`** brings server walkers into client code:

```jac
sv import from main {
    AddTask, ListTasks, ToggleTask, DeleteTask,
    GenerateShoppingList, GetShoppingList, ClearShoppingList
}
```

The `sv` prefix means "server import" -- it lets client code reference server-side walkers so it can spawn them.

Then in the frontend methods:

```jac
# Function style (Parts 3-6):
task = await add_task(task_text.strip());

# Walker style (Part 7):
result = root spawn AddTask(title=task_text.strip());
new_task = result.reports[0];
```

The key pattern: **`root spawn Walker(params)`** creates a walker and starts it at root. The walker traverses the graph, and whatever it `report`s ends up in `result.reports`.

**walker:priv -- Per-User Data Isolation**

Walkers can be marked with access modifiers:

- **`walker AddTask`** -- public, anyone can spawn it
- **`walker:priv AddTask`** -- private, requires authentication

When you use `walker:priv`, the walker runs on the authenticated user's **own private root node**. User A's tasks are completely invisible to User B -- same code, isolated data, enforced by the runtime. The complete walker version below uses `:priv` on all walkers, combined with the authentication you learned in Part 6.

**The Complete Walker Version**

To try the walker-based version, create a new project:

```bash
jac create day-planner-v2 --use client --skip
cd day-planner-v2
```

You'll create these files:

```
day-planner-v2/
├── main.jac                # Server: nodes, AI, walkers
├── frontend.cl.jac         # Client: state, UI, method declarations
├── frontend.impl.jac       # Client: method implementations
└── styles.css              # Styles
```

**Run It**

The complete source files for this part:

- [`part7-walkers/main.jac`](part7-walkers/main.jac) -- server-side nodes, AI types, and all walkers (`AddTask`, `ListTasks`, `ToggleTask`, `DeleteTask`, `GenerateShoppingList`, `GetShoppingList`, `ClearShoppingList`)
- [`part7-walkers/frontend.cl.jac`](part7-walkers/frontend.cl.jac) -- client-side UI with `sv import` for walker spawning
- [`part7-walkers/frontend.impl.jac`](part7-walkers/frontend.impl.jac) -- method implementations using `root spawn Walker()` instead of `await func()`
- [`part7-walkers/styles.css`](part7-walkers/styles.css) -- styles (same as Part 6)

```bash
export ANTHROPIC_API_KEY="your-key"
jac start main.jac
```

Open [http://localhost:8000](http://localhost:8000). You should see a login screen -- that's authentication working with `walker:priv`.

1. **Sign up** with any username and password
2. **Add tasks** -- they auto-categorize just like Part 5
3. **Try the meal planner** -- type "spaghetti bolognese for 4" and click Generate
4. **Refresh the page** -- your data persists (it's in the graph)
5. **Log out and sign up as a different user** -- you'll see a completely empty app. Each user gets their own graph.
6. **Restart the server** -- all data persists for both users

**What You Learned**

This part introduced Jac's Object-Spatial Programming paradigm:

- **`walker`** -- mobile code that traverses the graph
- **`can X with NodeType entry`** -- ability that fires when a walker enters a specific node type
- **`can X with NodeType exit`** -- ability that fires when leaving a node type
- **`visit [-->]`** -- move the walker to all connected nodes
- **`here`** -- the node the walker is currently visiting
- **`self`** -- the walker itself (its state and properties)
- **`visitor`** -- inside a node ability, the walker that's visiting
- **`report { ... }`** -- send data back, collected in `.reports`
- **`disengage`** -- stop traversal immediately
- **`root spawn Walker()`** -- create and start a walker at a node
- **`result.reports[0]`** -- access the walker's reported data
- **`walker:priv`** -- per-user walker with data isolation
- **`sv import`** -- import server walkers into client code

**When to use each approach:**

| Approach | Best For |
|----------|----------|
| `def:pub` functions | Direct data operations, simple CRUD, quick prototyping |
| Walkers | Graph traversal, multi-step operations, deep/recursive graphs |
| `walker:priv` | Per-user data isolation via private root nodes |
| Node abilities | When the logic naturally belongs to the data type |
| Walker abilities | When the logic naturally belongs to the traversal |

---

## Summary

Over seven parts, you built a complete app and then reimplemented it using OSP:

| Parts | What You Built | What It Teaches |
|-------|----------------|-----------------|
| 1–4 | Working day planner | Core syntax, graph data, reactive frontend |
| 5 | + AI features | AI delegation, structured output, semantic types |
| 6 | + Auth & multi-file | Authentication, declaration/implementation split |
| 7 | OSP reimplementation | Walkers, abilities, graph traversal |

Here's a quick reference of every Jac concept covered in this tutorial:

**Data & Types:** `node`, `edge`, `obj`, `enum`, `has`, `glob`, `sem`, type annotations, `str | None` unions

**Graph:** `root`, `++>` (create + connect), `+>: Edge :+>` (typed edge), `[root-->]` (query), `(?:Type)` (filter), `del` (delete)

**Functions:** `def`, `def:pub`, `by llm()`, `lambda`, `async`/`await`, docstrings

**Walkers:** `walker`, `walker:priv`, `can with Type entry/exit`, `visit`, `here`, `self`, `visitor`, `report`, `disengage`, `spawn`

**Frontend:** `cl`, `JsxElement`, reactive `has`, `can with entry`, `can with [deps] entry`, JSX expressions, `sv import`

**Structure:** `import from`, `cl import`, `sv import`, `impl`, declaration/implementation split

**Auth:** `jacSignup`, `jacLogin`, `jacLogout`, `jacIsLoggedIn`

---

## Next Steps

- **Deploy** -- [Deploy to Kubernetes](../production/kubernetes.md) with `jac-scale`
- **Go deeper on walkers** -- [Object-Spatial Programming](../language/osp.md) covers advanced graph patterns
- **More AI** -- [byLLM Quickstart](../ai/quickstart.md) for standalone examples and [Agentic AI](../ai/agentic.md) for tool-using agents
- **Examples** -- [LittleX (Twitter Clone)](../examples/littlex.md), [RAG Chatbot](../examples/rag-chatbot.md)
- **Language Reference** -- [Full Language Reference](../../reference/language/index.md) for complete syntax documentation
