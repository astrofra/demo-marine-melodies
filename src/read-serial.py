import asyncio
import aioserial

async def read_serial(ser):
    while True:
        # Check if incoming bytes are waiting to be read from the serial input
        # buffer.
        if ser.in_waiting > 0:
            # Read the bytes and convert from binary array to ASCII
            data = await ser.read_async(ser.in_waiting)
            data_str = data.decode('ascii')
            # Print the incoming string without putting a new-line
            # ('\n') automatically after every print()
            print(data_str, end='')

        # Put the rest of your code you want here

        # Sleep 10 ms (0.01 sec) once per loop to let
        # other tasks run during this time.
        await asyncio.sleep(0.01)

async def main():
    ser = aioserial.AioSerial(port='COM3', baudrate=9600)
    await read_serial(ser)

if __name__ == '__main__':
    asyncio.run(main())


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
