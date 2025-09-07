import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Map "mo:base/HashMap";
import Iter "mo:base/Iter";
actor Assistant
    {
        public query func greet(name : Text) : async Text 
            {
                return "Hello, " # name # "!";
            };

        type ToDo = 
            {
                description: Text;
                completed: Bool;
            };


        func naturalHash(n: Nat) : Hash.Hash
            {
                Text.hash(Nat.toText(n))
            };

        var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, naturalHash);
        var nextID: Nat = 0;

        public query func getTodos() : async [ToDo]
            {
                Iter.toArray(todos.vals());
            };

        public query func addTodo(description: Text) : async Nat
            {
                let id = nextID;
                todos.put(id, {description = description; completed = false});
                nextID += 1;
                id
            };

        public func completeToDo(id: Nat): async ()
            {
                ignore do ?
                    {
                        let description = todos.get(id)!.description;
                        todos.put(id, {description; completed = true});
                    };
            };

        public query func showTodos() : async Text
            {
                var output : Text = "\nTO-DO\n";
                for (todo: ToDo in todos.vals())
                    {
                        output #= "\n" # todo.description;
                        if (todo.completed)
                            {
                                output #= "+";
                            };
                    };
                output # "\n"
            };

        public func clearCompleted() : async ()
            {
                todos := Map.mapFilter<Nat, ToDo, ToDo>(todos, Nat.equal, naturalHash, 
                func(_, todo)
                    {
                        if (todo.completed) null else ?todo
                    });
            };
    };
