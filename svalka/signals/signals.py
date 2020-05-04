#!/usr/bin/env python3
import signal
import sys
import logging
import time

root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)

def signal_siginit(sig, frame):
    logging.debug('You pressed Ctrl+C!')

def signal_stp(sig, frame):
    logging.debug('You pressed Ctrl+Z')

def signal_stop(sig, frame):
    logging.debug('Nice try!!')

def fibonacci(n):
    a = 0
    b = 1
    if n < 0:
        print("Incorrect input")
    elif n == 0:
        return a
    elif n == 1:
        return b
    else:
        for i in range(2,n):
            c = a + b
            a = b
            b = c
            time.sleep(2)
            logging.debug(b)
        return b

def main():
    signal.signal(signal.SIGINT, signal_siginit)
    signal.signal(signal.SIGTSTP, signal_stp)
    signal.signal(signal.SIGSTOP, signal_stop)

    fibonacci(100)


if __name__ == "__main__":
    main()