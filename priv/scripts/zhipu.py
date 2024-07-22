import argparse
from langchain_zhipu import ChatZhipuAI
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

# def emit_event(event_name, data):
#     print(f">-[{event_name}]>>{data}")

def main():
    parser = argparse.ArgumentParser(description="Chat with ZhipuAI.")
    parser.add_argument('-m', '--message', type=str, required=True, help='Message to send to ZhipuAI')
    args = parser.parse_args()

    for x in ChatZhipuAI().stream(args.message):
        print(x.content, end="")

    print(">-[END]>>")

if __name__ == "__main__":
    main()