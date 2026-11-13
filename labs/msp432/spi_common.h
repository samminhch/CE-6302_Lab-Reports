#pragma once

#include <msp.h>
#include <stddef.h>

#define SPI_CLK_PIN  BIT5 /* P1.5: UCB0CLK */
#define SPI_SIMO_PIN BIT6 /* P1.6: UCB0SIMO (MOSI) */
#define SPI_SOMI_PIN BIT7 /* P1.7: UCB0SOMI (MISO) */

#define SPI_SHARED_CONFIG                                        \
  EUSCI_B_CTLW0_SYNC       /* Synchronous SPI Mode */            \
      | EUSCI_B_CTLW0_MSB  /* Transmit MSB first (e.g. [N:0]) */ \
      | EUSCI_B_CTLW0_CKPH /* Read on *rising*; Write on *falling* edge */

// Test Packet
static const uint8_t PACKET[] = {0x7D, 0xAA, 0x33, 0x77};
#define PACKET_SIZE (sizeof(PACKET) / sizeof(PACKET[0]))
