import time
import os

from langchain_zhipu import ChatZhipuAI

from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

def emit_event(event_name, data=""):
    print(f">-[{event_name}]>>{data}")
    # time.sleep(0.1)

def process_input(input_str):
    # timestamp = time.strftime("%H:%M:%S", time.localtime())
    return input_str

def main():
    chat = ChatZhipuAI()
    while True:
        input_str = input("")
        if input_str.lower() in ['exit', 'quit']:
            break
        question = process_input(input_str)
        for x in chat.stream(question):
            if isinstance(x, str):
                emit_event('chunk', x)
            else:
                emit_event('chunk', x.content)
        emit_event('end')

if __name__ == "__main__":
    main()
