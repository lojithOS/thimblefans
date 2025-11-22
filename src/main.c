#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <hidapi/hidapi.h>
#include <fcntl.h>
#include <sys/file.h>

#define VENDOR_ID 0x0cf2
#define PRODUCT_ID 0xa102
#define LOCK_FILE "/var/run/fan_speed_control.lock"

void send_command(hid_device *device, unsigned char *data, size_t length) {
    hid_write(device, data, length);
}

void set_speed(hid_device *device, int speed) {
    float rpm = 200.0 + 1900.0 * (speed / 100.0);
    unsigned char speed_byte = (unsigned char)(rpm / 21.0);
    for (int i = 0; i < 3; i++) {
        unsigned char command[4] = {224, 32 + i, 0, speed_byte};
        send_command(device, command, sizeof(command));
        usleep(100000);
    }
}

float get_cpu_temp() {
    const char *path = "/sys/class/hwmon/hwmon1/temp1_input";
    
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        return -1.0f;
    }

    int temp_raw;
    if (fscanf(file, "%d", &temp_raw) != 1) {
        fclose(file);
        return -1.0f;
    }
    fclose(file);

    float temp = (temp_raw > 2000) ? temp_raw / 1000.0f : (float)temp_raw;
    return temp;
}

int main() {
    int lock_fd = open(LOCK_FILE, O_RDWR | O_CREAT, 0644);
    if (lock_fd < 0) {
        perror("Unable to open lock file");
        return 1;
    }
    if (flock(lock_fd, LOCK_EX | LOCK_NB) < 0) {
        fprintf(stderr, "Another instance is already running.\n");
        close(lock_fd);
        return 1;
    }

    if (hid_init()) {
        fprintf(stderr, "HID initialization failed\n");
        close(lock_fd);
        return 1;
    }

    hid_device *handle = hid_open(VENDOR_ID, PRODUCT_ID, NULL);
    if (!handle) {
        fprintf(stderr, "Unable to open HID device\n");
        hid_exit();
        close(lock_fd);
        return 1;
    }

    while(1) {
        float temp = get_cpu_temp();
        if (temp < 0) {
            fprintf(stderr, "Failed to read CPU temperature\n");
            break;
        }

        int speed;
        if (temp < 50.0f) {
            speed = 25;;
        } else if (temp < 60.0f) {
            speed = 45;
        } else {
            speed = 55;
        }
        set_speed(handle, speed);
        sleep(6);
    }

    hid_close(handle);
    hid_exit();

    close(lock_fd);
    unlink(LOCK_FILE);
    return 0;
}

