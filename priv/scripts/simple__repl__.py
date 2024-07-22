import time  # 导入time模块

# script.py
def emit_event(event_name, data):
    print(f">-[{event_name}]>>{data}")
    time.sleep(0.2)  # 在打印之后休眠0.1秒

emit_event('text', 'Human: ')
emit_event('chunk', '你')
emit_event('chunk', '说的')
emit_event('chunk', '都对')
emit_event('chunk', '!')
emit_event('chunk', '\n')
emit_event('chunk', '很对！')
emit_event('final', '你说的都对!\n很对！')
emit_event('info', '这是一个脚本测试。\n')


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