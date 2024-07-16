from langchain_zhipu import ChatZhipuAI

from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

for x in ChatZhipuAI().stream("请告诉我你的模型名称"):
    print(x.content)
