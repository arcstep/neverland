# script.py
def emit_event(event_name, data):
    print(f">-[{event_name}]>> {data}")

emit_event('start', 'Script started')
# ... 在脚本中执行操作 ...
emit_event('progress', '50% complete')
# ... 更多操作 ...
emit_event('finish', 'Script finished')
