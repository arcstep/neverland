####################################################################################################
# list functions
globals_copy = globals().copy()
allowed_functions = [name for name, obj in globals_copy.items() if callable(obj) and not name.startswith('__')]
print(allowed_functions)

# execute function
def execute_function(func_name, *args):
    if func_name in allowed_functions:
        print(func_name, *args)
        function = globals_copy.get(func_name)
        function(*args)
    else:
        print(f"Function '{func_name}' is not allowed.")

# REPL
while True:
    user_input = input("")
    if user_input.lower() == 'exit':
        break
    try:
        parts = user_input.split('(', 1)
        func_name = parts[0].strip()
        if len(parts) > 1:
            args_str = parts[1].rstrip(')')
            args = eval(f"[{args_str}]")
        else:
            args = []
        
        execute_function(func_name, *args)
    except Exception as e:
        print(f"An error occurred: {e}")