import time

def emit_event(event_name, data):
    print(f">-[{event_name}]>>{data}")
    time.sleep(0.1)

def process_input(input_str):
    timestamp = time.strftime("%H:%M:%S", time.localtime())
    return f"{input_str} at {timestamp}"

def main():
    while True:
        try:
            input_str = input("请输入字符串: ")
            if input_str.lower() == 'exit':
                break
            combined_str = process_input(input_str)
            for char in combined_str:
                emit_event('chunk', char)
        except (EOFError, KeyboardInterrupt):
            break

if __name__ == "__main__":
    main()
