"""Implementations for the Day Planner frontend."""

impl app.fetchTasks -> None {
    tasksLoading = True;
    tasks = await get_tasks();
    tasksLoading = False;
}

impl app.addTask -> None {
    if not taskText.strip() { return; }
    task = await add_task(taskText.strip());
    tasks = tasks.concat([task]);
    taskText = "";
}

impl app.toggleTask(id: str) -> None {
    await toggle_task(id);
    tasks = tasks.map(
        lambda t: any -> any {
            if t.id == id {
                return {
                    "id": t.id, "title": t.title,
                    "done": not t.done, "category": t.category
                };
            }
            return t;
        }
    );
}

impl app.deleteTask(id: str) -> None {
    await delete_task(id);
    tasks = tasks.filter(
        lambda t: any -> bool { return t.id != id; }
    );
}

impl app.handleLogin -> None {
    error = "";
    if not username.strip() or not password {
        error = "Please fill in all fields";
        return;
    }
    loading = True;
    success = await jacLogin(username, password);
    loading = False;
    if success {
        isLoggedIn = True;
        username = "";
        password = "";
    } else {
        error = "Invalid username or password";
    }
}

impl app.handleSignup -> None {
    error = "";
    if not username.strip() or not password {
        error = "Please fill in all fields";
        return;
    }
    if len(password) < 4 {
        error = "Password must be at least 4 characters";
        return;
    }
    loading = True;
    result = await jacSignup(username, password);
    loading = False;
    if result["success"] {
        isLoggedIn = True;
        username = "";
        password = "";
    } else {
        error = result["error"] if result["error"] else "Signup failed";
    }
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;
    isSignup = False;
    tasks = [];
    ingredients = [];
}

impl app.handleSubmit(e: any) -> None {
    e.preventDefault();
    if isSignup { await handleSignup(); }
    else { await handleLogin(); }
}

impl app.handleTaskKeyPress(e: any) -> None {
    if e.key == "Enter" { addTask(); }
}

impl app.fetchShoppingList -> None {
    ingredients = await get_shopping_list();
}

impl app.generateList -> None {
    if not mealText.strip() { return; }
    generating = True;
    ingredients = await generate_list(mealText.strip());
    generating = False;
}

impl app.clearList -> None {
    await clear_shopping_list();
    ingredients = [];
    mealText = "";
}

impl app.handleMealKeyPress(e: any) -> None {
    if e.key == "Enter" { generateList(); }
}

impl app.getTotal -> float {
    total = 0.0;
    for ing in ingredients {
        total = total + ing.cost;
    }
    return total;
}
