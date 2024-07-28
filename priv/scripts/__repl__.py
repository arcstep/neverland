import ast
import sys
import io

def global_vars():
    return [name for name, obj in globals().items() if not name.startswith('__')]

class REPL:
    def __init__(self):
        self.globals_copy = globals().copy()

    def start(self):
        while True:
            try:
                user_input = input("")
                if user_input.lower() == 'exit':
                    break
                # 允许执行表达式，但不允许定义变量、函数或类
                eval_result = eval(user_input, self.globals_copy)
                if eval_result is not None:
                    print(eval_result)
            except EOFError:
                break
            except Exception as e:
                print(f"An error occurred: {e}")

# 创建 REPL 实例并启动
repl_instance = REPL()
repl_instance.start()