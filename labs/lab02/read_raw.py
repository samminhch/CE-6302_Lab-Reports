import serial
import matplotlib.pyplot as plt

# --- STEP 1 open the port ----
with serial.Serial("/dev/ttyACM0", 115200) as ser:
    while True:
        line: str = ser.readline().decode(errors="ignore").strip()
        result = tuple(map(int, line.split(",")))
        if len(result) == 3:
            ax_c, ay_c, az_c = tuple(map(int, line.split(",")))
            print(f"{ax_c=}\t{ay_c=}\t{az_c=}")
