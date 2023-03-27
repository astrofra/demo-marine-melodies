import serial

s = serial.Serial('COM3', baudrate=9600)

serialString = ""  # Used to hold data coming over UART
while True:
    while True:
        # Wait until there is data waiting in the serial buffer
        print(s.in_waiting)
        if s.in_waiting > 0:

            # Read data out of the buffer until a carraige return / new line is found
            serialString = s.readline()

            # Print the contents of the serial data
            # try:
            #     print(int(serialString.decode("Ascii")))
            # except:
            #     pass

            break

# while True:
#     res = s.read()
#     print(res)