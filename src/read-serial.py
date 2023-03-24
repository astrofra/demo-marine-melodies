import asyncio
import serial_asyncio

async def read_serial_data(serial_port):
    while True:
        line = await serial_port.readline()
        print(f'Received: {line.decode().strip()}')

async def main():
    # Replace 'COM3' with the serial port name on your system
    port = 'COM1'
    baudrate = 9600 # 115200

    # Create a connection to the serial port
    serial_port = await serial_asyncio.open_serial_connection(url=port, baudrate=baudrate)

    # Start the async task to read data from the serial port
    read_task = asyncio.create_task(read_serial_data(serial_port))

    # You can add other async tasks here
    # e.g., asyncio.create_task(some_other_async_function())

    # Wait for the read task to complete (in this case, it will never complete)
    await read_task

if __name__ == '__main__':
    asyncio.run(main())
