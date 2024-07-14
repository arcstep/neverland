import time

def emit_event(event_name, data):
    print(f">-[{event_name}]>>{data}")
    # time.sleep(0.1)  # 在打印之后休眠0.2秒

def process_input(input_str):
    # 获取当前时间戳
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    # 组合字符串和时间戳
    return f"{input_str} at {timestamp}"

def main():
    while True:
        try:
            # 接受输入
            input_str = input("请输入字符串: ")
            if input_str.lower() == 'exit':  # 如果输入exit，则退出循环
                break
            combined_str = process_input(input_str)
            # 逐个字符打印
            for char in combined_str:
                emit_event('chunk', char)
        except (EOFError, KeyboardInterrupt):
            break  # 处理输入流被关闭的情况，如果用户按Ctrl+C，也退出循环

if __name__ == "__main__":
    main()
