from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)
import os

from langchain.memory import ConversationBufferMemory, ConversationBufferWindowMemory
win = ConversationBufferWindowMemory(k=20, return_messages=True)

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