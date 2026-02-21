"""AI Day Planner -- Client-Side UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

sv import from main {
    get_tasks, add_task, toggle_task, delete_task,
    generate_list, get_shopping_list, clear_shopping_list
}

import "./styles.css";

def:pub app -> JsxElement {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        tasks: list = [],
        taskText: str = "",
        tasksLoading: bool = True,
        mealText: str = "",
        ingredients: list = [],
        generating: bool = False;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchTasks();
            fetchShoppingList();
        }
    }

    # Method declarations -- bodies are in frontend.impl.jac
    async def fetchTasks -> None;
    async def addTask -> None;
    async def toggleTask(id: str) -> None;
    async def deleteTask(id: str) -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    def handleTaskKeyPress(e: any) -> None;
    async def fetchShoppingList -> None;
    async def generateList -> None;
    async def clearList -> None;
    def handleMealKeyPress(e: any) -> None;
    def getTotal -> float;

    if checkingAuth {
        return
            <div class="auth-loading">Loading...</div>;
    }

    if isLoggedIn {
        totalCost = getTotal();
        remaining = len(tasks.filter(
            lambda t: any -> bool { return not t.done; }
        ));
        return
            <div class="container">
                <div class="header">
                    <div>
                        <h1>AI Day Planner</h1>
                        <p class="subtitle">
                            Task management with AI-powered meal planning
                        </p>
                    </div>
                    <button class="btn-signout" onClick={handleLogout}>
                        Sign Out
                    </button>
                </div>
                <div class="two-column">
                    <div class="column">
                        <h2>Today's Tasks</h2>
                        <div class="input-row">
                            <input
                                class="input"
                                value={taskText}
                                onChange={lambda e: any -> None { taskText = e.target.value; }}
                                onKeyPress={handleTaskKeyPress}
                                placeholder="What needs to be done today?"
                            />
                            <button
                                class="btn-add"
                                onClick={lambda -> None { addTask(); }}
                            >
                                Add
                            </button>
                        </div>
                        {(
                            <div class="loading-msg">Loading tasks...</div>
                        ) if tasksLoading else (
                            <div>
                                {(
                                    <div class="empty-msg">
                                        No tasks yet. Add one above!
                                    </div>
                                ) if len(tasks) == 0 else (
                                    <div>
                                        {[
                                            <div key={t.id} class="task-item">
                                                <input
                                                    type="checkbox"
                                                    checked={t.done}
                                                    onChange={lambda -> None { toggleTask(t.id); }}
                                                />
                                                <span class={"task-title " + ("task-done" if t.done else "")}>
                                                    {t.title}
                                                </span>
                                                {(
                                                    <span class="category">{t.category}</span>
                                                ) if t.category and t.category != "other" else None}
                                                <button
                                                    class="btn-delete"
                                                    onClick={lambda -> None { deleteTask(t.id); }}
                                                >
                                                    X
                                                </button>
                                            </div> for t in tasks
                                        ]}
                                    </div>
                                )}
                            </div>
                        )}
                        <div class="count">{remaining} tasks remaining</div>
                    </div>
                    <div class="column">
                        <h2>Meal Shopping List</h2>
                        <div class="input-row">
                            <input
                                class="input"
                                value={mealText}
                                onChange={lambda e: any -> None { mealText = e.target.value; }}
                                onKeyPress={handleMealKeyPress}
                                placeholder="e.g. 'chicken stir fry for 4'"
                            />
                            <button
                                class="btn-generate"
                                onClick={lambda -> None { generateList(); }}
                                disabled={generating}
                            >
                                {("Generating..." if generating else "Generate")}
                            </button>
                        </div>
                        {(
                            <div class="generating-msg">Generating with AI...</div>
                        ) if generating else (
                            <div>
                                {(
                                    <div class="empty-msg">
                                        Enter a meal above to generate ingredients.
                                    </div>
                                ) if len(ingredients) == 0 else (
                                    <div>
                                        {[
                                            <div key={ing.name} class="ingredient-item">
                                                <div class="ing-info">
                                                    <span class="ing-name">{ing.name}</span>
                                                    <span class="ing-qty">
                                                        {ing.quantity} {ing.unit}
                                                    </span>
                                                </div>
                                                <div class="ing-meta">
                                                    {(
                                                        <span class="carb-badge">Carbs</span>
                                                    ) if ing.carby else None}
                                                    <span class="ing-cost">
                                                        ${ing.cost.toFixed(2)}
                                                    </span>
                                                </div>
                                            </div> for ing in ingredients
                                        ]}
                                        <div class="shopping-footer">
                                            <span class="total">
                                                Total: ${totalCost.toFixed(2)}
                                            </span>
                                            <button
                                                class="btn-clear"
                                                onClick={lambda -> None { clearList(); }}
                                            >
                                                Clear
                                            </button>
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </div>
            </div>;
    }

    return
        <div class="auth-container">
            <div class="auth-card">
                <h1 class="auth-title">AI Day Planner</h1>
                <p class="auth-subtitle">
                    {("Create your account" if isSignup else "Welcome back")}
                </p>
                {(
                    <div class="auth-error">{error}</div>
                ) if error else None}
                <form onSubmit={handleSubmit}>
                    <div class="form-field">
                        <label class="form-label">Username</label>
                        <input
                            type="text"
                            value={username}
                            onChange={lambda e: any -> None { username = e.target.value; }}
                            placeholder="Enter username"
                            class="auth-input"
                        />
                    </div>
                    <div class="form-field">
                        <label class="form-label">Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={lambda e: any -> None { password = e.target.value; }}
                            placeholder="Enter password"
                            class="auth-input"
                        />
                    </div>
                    <button type="submit" disabled={loading} class="auth-submit">
                        {(
                            "Processing..."
                            if loading
                            else ("Create Account" if isSignup else "Sign In")
                        )}
                    </button>
                </form>
                <div class="auth-toggle">
                    <span class="auth-toggle-text">
                        {(
                            "Already have an account? "
                            if isSignup
                            else "Don't have an account? "
                        )}
                    </span>
                    <button
                        type="button"
                        onClick={lambda -> None { isSignup = not isSignup; error = ""; }}
                        class="auth-toggle-btn"
                    >
                        {("Sign In" if isSignup else "Sign Up")}
                    </button>
                </div>
            </div>
        </div>;
}
