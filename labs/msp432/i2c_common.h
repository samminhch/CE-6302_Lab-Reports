#pragma once
#include <msp.h>
#include <stddef.h>

#define SDA_PIN BIT6 /* EUSCI_B0 (P1.6) */
#define SCK_PIN BIT7 /* EUSCI_B0 (P1.7) */

#define RTC_SLAVE_ADDR 0x68 /* Adafruit PFC8523 RTC I2C 7-Bitg slave address */
#define RTC_REG_ADDR   0x03 /* The `seconds` register */
