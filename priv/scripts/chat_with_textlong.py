import os
import sys
sys.path.append(os.path.expanduser('~/github/textlong'))

from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

from langchain_zhipu import ChatZhipuAI
from textlong import WritingProject, list_projects, init_project, is_project_existing

# 从标准输入获得一个项目ID
project_id = input("")
p = WritingProject(llm=ChatZhipuAI(model="glm-4-flash"), project_id=project_id)

# print(list_projects())
# p.chat("你好，我是一个AI。")

