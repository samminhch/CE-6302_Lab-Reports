#include <msp.h>
#include <stddef.h>
#include "spi_common.h"

#define LED_RED_PIN   BIT0
#define BUTTON_S2_PIN BIT4

static volatile size_t packet_idx      = 0;
static volatile uint8_t button_pressed = 0;

static void delay_ms(uint32_t ms) {
  for (size_t i = 0; i < ms * 1000; i++) { __NOP(); }
}

static void init_led() {
  // Set LED to GPIO mode
  P1->SEL0 &= ~LED_RED_PIN;
  P1->SEL1 &= ~LED_RED_PIN;

  P1->DIR |= LED_RED_PIN;  // [0] = INPUT; [1] = OUTPUT
  P1->OUT &= ~LED_RED_PIN; // [0] = Pull-Down; [1] = Pull-Up
}

static void init_button() {
  // Set BUTTON to GPIO mode
  P1->SEL0 &= ~BUTTON_S2_PIN;
  P1->SEL1 &= ~BUTTON_S2_PIN;

  P1->DIR &= ~BUTTON_S2_PIN;
  P1->REN |= BUTTON_S2_PIN;
  P1->OUT |= BUTTON_S2_PIN;

  P1->IES |= BUTTON_S2_PIN;  // Set interrupt on falling edge
  P1->IFG &= ~BUTTON_S2_PIN; // Clear any interrupt flags before enabling
  P1->IE  |= BUTTON_S2_PIN;  // Enable button interrupt
}

static void init_clock() {
  CS->KEY  = CS_KEY_VAL;
  CS->CTL0 = CS_CTL0_DCORSEL_2;                           // 6 MHz DCO
  CS->CTL1 = CS_CTL1_SELM__DCOCLK | CS_CTL1_SELS__DCOCLK; // MCLK = SMCLK = 6 MHz
  CS->KEY  = 0; // Prevent further modification to the system clock
}

static void init_spi() {
  P1->SEL0 |= (SPI_CLK_PIN | SPI_SIMO_PIN | SPI_SOMI_PIN);
  P1->SEL1 &= ~(SPI_CLK_PIN | SPI_SIMO_PIN | SPI_SOMI_PIN);

  EUSCI_B0->CTLW0 = EUSCI_B_CTLW0_SWRST; // Pauses SPI for configuration

  EUSCI_B0->CTLW0 |= SPI_SHARED_CONFIG |     // Synchronous (SPI) mode
                     EUSCI_B_CTLW0_MST |     // Master mode
                     EUSCI_B_CTLW0_UCSSEL_2; // SMCLK as clock source

  EUSCI_B0->BRW    = 0x02;                 // Set the clock to 6 MHz / 2 = 3 MHz
  EUSCI_B0->CTLW0 &= ~EUSCI_B_CTLW0_SWRST; // Start SPI
}

static void transmit_spi(uint8_t data) {
  while (!(EUSCI_B0->IFG & EUSCI_B_IFG_TXIFG));
  EUSCI_B0->TXBUF = data;

  while (!(EUSCI_B0->IFG & EUSCI_B_IFG_RXIFG));
  (void)EUSCI_B0->RXBUF;
}

void PORT1_IRQHandler(void) {
  if (!(P1->IFG & BIT4)) return;

  P1->IFG        &= ~BUTTON_S2_PIN;
  P1->IE         &= ~BUTTON_S2_PIN; // hardware debounce
  button_pressed  = 1;
}

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;

  init_button();
  init_led();
  init_clock();
  init_spi();

  NVIC_EnableIRQ(PORT1_IRQn);
  __enable_irq();

  while (1) {
    if (button_pressed) {
      P1->OUT |= LED_RED_PIN;

      transmit_spi(PACKET[packet_idx]);
      packet_idx = (packet_idx + 1) % PACKET_SIZE;

      delay_ms(250);
      P1->OUT        &= ~LED_RED_PIN;
      button_pressed  = 0;
      P1->IFG        &= ~BUTTON_S2_PIN;
      P1->IE         |= BUTTON_S2_PIN; // enable interrupt again
    };

    __wfi();
  }

  return 0;
}
