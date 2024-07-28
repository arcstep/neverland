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