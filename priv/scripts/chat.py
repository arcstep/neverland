import argparse
from langchain_zhipu import ChatZhipuAI
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

def emit_event(event_name, data):
    print(f">-[{event_name}]>>{data}")

def chat(message: str):
    for x in ChatZhipuAI().stream(message):
        print(x.content, end="")

    print(">-[END]>>")


# Example

chat("请帮我起一个公司名字") # chat with ZhipuAI