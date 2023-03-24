import serial
import time # Optional (required if using time.sleep() below)

ser = serial.Serial(port='COM3', baudrate=9600)

while (True):
    # Check if incoming bytes are waiting to be read from the serial input 
    # buffer.
    # NB: for PySerial v3.0 or later, use property `in_waiting` instead of
    # function `inWaiting()` below!
    if (ser.inWaiting() > 0):
        # read the bytes and convert from binary array to ASCII
        data_str = ser.read(ser.inWaiting()).decode('ascii') 
        # print the incoming string without putting a new-line
        # ('\n') automatically after every print()
        print(data_str, end='') 

    # Put the rest of your code you want here
    
    # Optional, but recommended: sleep 10 ms (0.01 sec) once per loop to let 
    # other threads on your PC run during this time. 
    time.sleep(0.01)

# import asyncio
# import serial_asyncio

# async def read_serial_data(serial_port):
#     while True:
#         line = await serial_port.readline()
#         print(f'Received: {line.decode().strip()}')

# async def main():
#     # Replace 'COM3' with the serial port name on your system
#     port = 'COM3'
#     baudrate = 9600 # 115200

#     # Create a connection to the serial port
#     serial_port = await serial_asyncio.open_serial_connection(url=port, baudrate=baudrate)

#     # Start the async task to read data from the serial port
#     read_task = asyncio.create_task(read_serial_data(serial_port))

#     # You can add other async tasks here
#     # e.g., asyncio.create_task(some_other_async_function())

#     # Wait for the read task to complete (in this case, it will never complete)
#     await read_task

# if __name__ == '__main__':
#     asyncio.run(main())
