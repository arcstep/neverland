from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)
import os

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_zhipu import ChatZhipuAI
from langchain_core.output_parsers import StrOutputParser
from textlong.memory import MemoryManager, WithMemoryBinding

# 定义chain
model = ChatZhipuAI()
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "给我一个名字即可，不要输出其他。"),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{input}"),
    ]
)
chain = prompt | model

# 定义记忆体
memory = MemoryManager()

# 记忆绑定管理
withMemoryChain = WithMemoryBinding(chain, memory)

def chat(message: str):
    for x in withMemoryChain.stream({"input": message}):
        print(x.content, end="")

    print(">-[END]>>")


# Example

# chat("请帮我起一个公司名字") # chat with ZhipuAI

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