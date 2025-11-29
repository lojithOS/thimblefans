#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <hidapi/hidapi.h>
#include <fcntl.h>
#include <sys/file.h>

#define VENDOR_ID 0x0cf2
#define PRODUCT_ID 0xa102
#define LOCK_FILE "/tmp/fan_speed_control.lock"
#define STATE_FILE "/tmp/fan_speed_control.state"

void send_command(hid_device *device, unsigned char *data, size_t length) {
    hid_write(device, data, length);
}

void set_speed(hid_device *device, int speed) {
    float rpm = 200.0 + 1900.0 * (speed / 100.0);
    unsigned char speed_byte = (unsigned char)(rpm / 21.0);
    fprintf(stderr, "Setting speed to %d%% (RPM: %.0f, Byte: %d)\n", speed, rpm, speed_byte);
    for (int i = 0; i < 3; i++) {
        unsigned char command[4] = {224, 32 + i, 0, speed_byte};
        send_command(device, command, sizeof(command));
        usleep(100000);
    }
}

float get_cpu_temp() {
    const char *path = "/sys/class/hwmon/hwmon3/temp1_input";
    
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

int calculate_speed(float temp) {
    if (temp < 30.0f) {
        return 30;
    } else if (temp >= 30.0f && temp < 55.0f) {
        return 60;
    } else if (temp >= 55.0f && temp < 85.0f) {
        return 70;
    } else {
        return 80;
    }
}

void write_state(float temp, int speed) {
    FILE *file = fopen(STATE_FILE, "w");
    if (file) {
        fprintf(file, "%.1f %d\n", temp, speed);
        fclose(file);
    }
}

int read_state(float *temp, int *speed) {
    FILE *file = fopen(STATE_FILE, "r");
    if (!file) {
        return -1;
    }
    int result = fscanf(file, "%f %d", temp, speed);
    fclose(file);
    return (result == 2) ? 0 : -1;
}

void print_usage(const char *prog) {
    fprintf(stderr, "Usage: %s [OPTION]\n", prog);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -speed     Show current fan speed percentage\n");
    fprintf(stderr, "  -temp      Show current CPU temperature\n");
    fprintf(stderr, "  -status    Show temperature and fan speed\n");
    fprintf(stderr, "  -help      Show this help message\n");
    fprintf(stderr, "  (no args)  Run fan control daemon\n");
}

int main(int argc, char *argv[]) {
    // Handle command-line arguments
    if (argc > 1) {
        if (strcmp(argv[1], "-speed") == 0) {
            float temp;
            int speed;
            if (read_state(&temp, &speed) == 0) {
                printf("%d%%\n", speed);
            } else {
                fprintf(stderr, "No state file found. Is the daemon running?\n");
                return 1;
            }
            return 0;
        } else if (strcmp(argv[1], "-temp") == 0) {
            float temp;
            int speed;
            if (read_state(&temp, &speed) == 0) {
                printf("%.1f°C\n", temp);
            } else {
                fprintf(stderr, "No state file found. Is the daemon running?\n");
                return 1;
            }
            return 0;
        } else if (strcmp(argv[1], "-status") == 0) {
            float temp;
            int speed;
            if (read_state(&temp, &speed) == 0) {
                printf("CPU Temperature: %.1f°C\n", temp);
                printf("Fan Speed: %d%%\n", speed);
            } else {
                fprintf(stderr, "No state file found. Is the daemon running?\n");
                return 1;
            }
            return 0;
        } else if (strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[1]);
            print_usage(argv[0]);
            return 1;
        }
    }

    // Daemon mode (no arguments)
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

        int speed = calculate_speed(temp);
        write_state(temp, speed);
        set_speed(handle, speed);
        sleep(2);
    }

    hid_close(handle);
    hid_exit();

    close(lock_fd);
    unlink(LOCK_FILE);
    unlink(STATE_FILE);
    return 0;
}

