"""AI Day Planner -- walker-based version with OSP."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> JsxElement {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="claude-sonnet-4-20250514");

# --- Enums ---

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, FITNESS, OTHER }

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, BUNCH }

# --- AI Types ---

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";

"""Categorize a task based on its title."""
def categorize(title: str) -> Category by llm();

"""Generate a shopping list of ingredients needed for a described meal."""
def generate_shopping_list(meal_description: str) -> list[Ingredient] by llm();

# --- Data Nodes ---

node Task {
    has id: str,
        title: str,
        done: bool = False,
        category: str = "other";
}

node ShoppingItem {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

# --- Task Walkers ---

walker:priv AddTask {
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

walker:priv ListTasks {
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

walker:priv ToggleTask {
    has task_id: str;

    can search with Root entry { visit [-->]; }

    can toggle with Task entry {
        if here.id == self.task_id {
            here.done = not here.done;
            report {
                "id": here.id,
                "done": here.done
            };
            disengage;
        }
    }
}

walker:priv DeleteTask {
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

# --- Shopping List Walkers ---

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        visit [-->];
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

walker:priv GetShoppingList {
    has items: list = [];

    can collect with Root entry { visit [-->]; }

    can gather with ShoppingItem entry {
        self.items.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can done with Root exit { report self.items; }
}

walker:priv ClearShoppingList {
    can collect with Root entry { visit [-->]; }

    can clear with ShoppingItem entry {
        del here;
        report {"cleared": True};
    }
}
