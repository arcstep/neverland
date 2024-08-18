import os
import sys
sys.path.append(os.path.expanduser('~/github/textlong'))

from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(), override=True)

from langchain_zhipu import ChatZhipuAI
from textlong import WritingProject, list_projects, init_project, is_project_existing

from langchain_community.llms import Tongyi

p = WritingProject(llm=Tongyi(model="qwen2-0.5b-instruct"), project_id="我的项目")

# print(list_projects())
# p.chat("你好，我是一个AI。")

