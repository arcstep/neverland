import ast
import sys
import io

class REPL:
    def __init__(self):
        # 列出允许的函数和变量
        self.globals_copy = globals().copy()
        self.allowed_names = [name for name, obj in self.globals_copy.items() if not name.startswith('__')]
        print(self.allowed_names)

    def is_allowed(self, node):
        # 检查节点是否只包含允许的函数和变量
        if isinstance(node, ast.Name):
            return node.id in self.allowed_names
        for child in ast.iter_child_nodes(node):
            if not self.is_allowed(child):
                return False
        return True

    def start(self):
        # REPL
        while True:
            user_input = input("")
            if user_input.lower() == 'exit':
                break
            try:
                # 尝试解析为表达式
                tree = ast.parse(user_input, mode='eval')
                if self.is_allowed(tree):
                    # 只执行允许表达式
                    result = eval(user_input, self.globals_copy)
                    print(result)
                else:
                    print("Error: Use of disallowed names.")
            except SyntaxError:
                try:
                    # 如果解析为表达式失败，尝试解析为语句
                    tree = ast.parse(user_input, mode='exec')
                    if all(self.is_allowed(node) for node in ast.walk(tree)):
                        # 捕获 exec 的输出
                        old_stdout = sys.stdout
                        sys.stdout = io.StringIO()
                        try:
                            exec(user_input, self.globals_copy)
                            output = sys.stdout.getvalue()
                        finally:
                            sys.stdout = old_stdout
                        if output:
                            print(output, end='')
                        else:
                            # 打印最后的运算结果
                            result = eval(user_input, self.globals_copy)
                            print(result)
                    else:
                        print("Error: Use of disallowed names.")
                except Exception as e:
                    print(f"An error occurred: {e}")
            except Exception as e:
                print(f"An error occurred: {e}")

# 创建 REPL 实例并启动
repl_instance = REPL()
repl_instance.start()