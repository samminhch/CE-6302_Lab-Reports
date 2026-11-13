#include <msp.h>

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // stop watchdog timer

  // Error LEDs
  P1->DIR |= BIT0;    // set BIT0 as OUTPUT
  P1->OUT &= ~(BIT0); // set BIT0 as LOW
  // clear secondary functions
  P1->SEL0 &= ~(BIT0);
  P1->SEL1 &= ~(BIT0);

  // RGB LEDs
  P2->DIR |= BIT0 | BIT1 | BIT2;    // set BIT0,1,2 as OUTPUTs
  P2->OUT &= ~(BIT0 | BIT1 | BIT2); // set BIT0,1,2 as LOW
  // clear secondary functions
  P2->SEL0 &= ~(BIT0 | BIT1 | BIT2);
  P2->SEL1 &= ~(BIT0 | BIT1 | BIT2);

  // Enable UART0 Pins
  // P1.2->RX
  // P1.3->TX
  P3->SEL0 |= BIT2 | BIT3;
  P3->SEL1 &= ~(BIT2 | BIT3);

  // UART0 Configuration
  // Enhanced Universal Serial Control Interface = EUSCI
  EUSCI_A2->CTLW0 = EUSCI_A_CTLW0_SWRST; // Clear previous configuration of UART

  // Add the configuration code here and enable UART interrupt
  EUSCI_A2->CTLW0 |= EUSCI_A_CTLW0_SSEL__SMCLK;
  EUSCI_A2->BRW    = 19; // 3MHz / 16 / 9600 (baud rate)
  EUSCI_A2->MCTLW  = (9 << EUSCI_A_MCTLW_BRF_OFS | EUSCI_A_MCTLW_OS16);
  EUSCI_A2->CTLW0 &= ~(EUSCI_A_CTLW0_SWRST);
  EUSCI_A2->IE    |= EUSCI_A_IE_RXIE;
  EUSCI_A2->IFG   &= ~(EUSCI_A_IE_RXIE);

  // enable NVIC for UART0
  NVIC->ISER[0] = 1 << (EUSCIA2_IRQn & 31);

  // enable global interrupts
  __enable_irq();

  while (1);
}

void delay() {
  volatile uint32_t i;
  for (i = 0; i < 100000; i++);
}

void EUSCIA2_IRQHandler() {
  // Don't do anything if the interrupt isn't UART RX
  if (!(EUSCI_A2->IFG & EUSCI_A_IFG_RXIFG)) return;

  // Get character from the RX buffer
  char c = EUSCI_A2->RXBUF;

  // Reset LED2 off
  P2->OUT &= ~(BIT0 | BIT1 | BIT2);

  switch (c) {
    case 'r':
      P2->OUT |= BIT0;
      break;
    case 'g':
      P2->OUT |= BIT1;
      break;
    case 'b':
      P2->OUT |= BIT2;
      break;
    default:
      // This was kinda messy since it kept
      // Erroring when trying to put a for loop
      P1->OUT ^= BIT0; // toggle Error LED on/off
      delay();
      P1->OUT ^= BIT0;
      delay();
      P1->OUT ^= BIT0;
      delay();
      P1->OUT ^= BIT0;
      delay();
  }
}
