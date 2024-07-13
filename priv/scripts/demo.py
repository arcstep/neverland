import time  # 导入time模块

# script.py
def emit_event(event_name, data):
    print(f">-[{event_name}]>>{data}")
    time.sleep(0.2)  # 在打印之后休眠0.1秒

emit_event('text', 'Human: ')
emit_event('chunk', '你')
emit_event('chunk', '说的')
emit_event('chunk', '都对')
emit_event('chunk', '!')
emit_event('chunk', '\n')
emit_event('chunk', '很对！')
emit_event('final', '你说的都对!\n很对！')
emit_event('info', '这是一个脚本测试。\n')
