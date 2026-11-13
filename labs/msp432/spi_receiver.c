#include <msp.h>
#include <stddef.h>
#include <stdio.h>
#include "spi_common.h"

#define RX_BUFFER_SIZE (PACKET_SIZE * 2)
#define LED_GREEN_PIN  BIT1

static volatile uint8_t received = 0;
static volatile uint8_t data;

int fputc(int c, FILE *fp) {
  (void)fp;
  while (!(EUSCI_A0->IFG & EUSCI_A_IFG_TXIFG));
  EUSCI_A0->TXBUF = (unsigned char)c;
  return c;
}

static void init_uart() {
  // P1.2 (RXD); P1.3 (TXD)
  P1->SEL0 |= BIT2 | BIT3;
  P1->SEL1 &= ~(BIT2 | BIT3);

  EUSCI_A0->CTLW0  = EUSCI_A_CTLW0_SWRST;
  EUSCI_A0->CTLW0 |= EUSCI_A_CTLW0_SSEL__SMCLK;
  EUSCI_A0->BRW    = 19; // 9600 Baud rate
  EUSCI_A0->MCTLW  = (9 << EUSCI_A_MCTLW_BRF_OFS | EUSCI_A_MCTLW_OS16);
  EUSCI_A0->CTLW0 &= ~EUSCI_A_CTLW0_SWRST;
}

static void init_led() {
  P2->DIR |= LED_GREEN_PIN;
  P2->OUT &= ~LED_GREEN_PIN;
}

static void init_spi() {
  // P1.5 (CLK); P1.6 (SIMO); P1.7 (SOMI)
  P1->SEL0 |= (SPI_CLK_PIN | SPI_SIMO_PIN | SPI_SOMI_PIN);
  P1->SEL1 &= ~(SPI_CLK_PIN | SPI_SIMO_PIN | SPI_SOMI_PIN);

  EUSCI_B0->CTLW0  = EUSCI_B_CTLW0_SWRST;
  EUSCI_B0->CTLW0 |= SPI_SHARED_CONFIG;

  EUSCI_B0->CTLW0 &= ~EUSCI_B_CTLW0_SWRST;

  // Enable receive interrupt
  EUSCI_B0->IE  |= EUSCI_B_IE_RXIE;
  EUSCI_B0->IFG &= ~EUSCI_B_IFG_RXIFG;
}

void EUSCIB0_IRQHandler() {
  if (!(EUSCI_B0->IFG & EUSCI_B_IFG_RXIFG)) { return; }

  data      = (uint8_t)EUSCI_B0->RXBUF;
  received  = 1;
  P2->OUT  ^= LED_GREEN_PIN;
}

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;

  init_uart();
  init_led();
  init_spi();

  NVIC_EnableIRQ(EUSCIB0_IRQn);
  __enable_interrupt();

  while (1) {
    // Empty out the ring buffer
    if (received) {
      printf("Received 0x%02X\tDecimal: %3u\r\n", data, data);
      received = 0;
    }
    __wfi();
  }

  return 0;
}
