import argparse
from langchain_zhipu import ChatZhipuAI
from dotenv import load_dotenv, find_dotenv

def main():
    # 加载环境变量
    load_dotenv(find_dotenv(), override=True)

    # 创建 ArgumentParser 对象
    parser = argparse.ArgumentParser(description="Chat with ZhipuAI.")
    # 添加命名参数
    parser.add_argument('-m', '--message', type=str, required=True, help='Message to send to ZhipuAI')

    # 解析命令行参数
    args = parser.parse_args()

    # 使用命令行参数作为消息
    for x in ChatZhipuAI().stream(args.message):
        print(x.content, end="")

if __name__ == "__main__":
    main()