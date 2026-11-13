#include <msp.h>
#include <stdbool.h>

static void send_string(char *str);
static void send_char(char s);

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // stop watchdog timer

  // Enable UART0 Pins
  // P1.2->RX
  // P1.3->TX
  P1->SEL0 |= BIT2 | BIT3;
  P1->SEL1 &= ~(BIT2 | BIT3);

  // UART0 Configuration
  // Enhanced Universal Serial Control Interface = EUSCI
  EUSCI_A0->CTLW0  = EUSCI_A_CTLW0_SWRST; // Clear previous configuration of UART
  EUSCI_A0->CTLW0 |= EUSCI_A_CTLW0_SSEL__SMCLK;
  EUSCI_A0->BRW    = 19; // 3MHz / 16 / 9600
  EUSCI_A0->MCTLW  = (9 << EUSCI_A_MCTLW_BRF_OFS | EUSCI_A_MCTLW_OS16);
  EUSCI_A0->CTLW0 &= ~(EUSCI_A_CTLW0_SWRST);

  // enable uart interrupt
  EUSCI_A0->IE  |= EUSCI_A_IE_RXIE;
  EUSCI_A0->IFG &= ~(EUSCI_A_IE_RXIE);

  // Enable UART2 Pins
  // P3.2->RX
  // P3.3->TX
  P3->SEL0 |= BIT2 | BIT3;
  P3->SEL1 &= ~(BIT2 | BIT3);

  // UART2 Configuration
  EUSCI_A2->CTLW0 = EUSCI_A_CTLW0_SWRST; // Clear previous configuration of UART
                                         // by setting reset
  EUSCI_A2->CTLW0 |= EUSCI_A_CTLW0_SSEL__SMCLK;
  EUSCI_A2->BRW    = 19; // 3MHz / 16 / 9600
  EUSCI_A2->MCTLW  = (9 << EUSCI_A_MCTLW_BRF_OFS | EUSCI_A_MCTLW_OS16);
  EUSCI_A2->CTLW0 &= ~(EUSCI_A_CTLW0_SWRST);

  // enable uart interrupt
  EUSCI_A2->IE  |= EUSCI_A_IE_RXIE;
  EUSCI_A2->IFG &= ~(EUSCI_A_IE_RXIE);

  // enable NVIC for UART0
  NVIC->ISER[0] = 1 << (EUSCIA0_IRQn & 31);
  // enable global interrupts
  __enable_irq();

  send_string("Enter r for red, g for green, b for blue!\r\n"); // send message

  while (1); // do nothing
}

void EUSCIA0_IRQHandler(void) {
  // Don't do anything if we didn't get
  if (!(EUSCI_A0->IFG & EUSCI_A_IFG_RXIFG)) return;

  char c = EUSCI_A0->RXBUF; // store data into character buffer, and clear flag
  send_char(c);             // display character through the SERIAL port
  char str[] = {c, '\r', '\n', '\0'};
  send_string(str);
}

void send_string(char *str) {
  int i = 0;
  while (str[i] != '\0') {
    while (!(EUSCI_A0->IFG & EUSCI_A_IFG_TXIFG)); // wait till TXBUF is empty (Check TXIFG flag)
    EUSCI_A0->TXBUF = str[i];                     // send character through buffer
    i++;
  }
}

void send_char(char s) {
  while (!(EUSCI_A2->IFG & EUSCI_A_IFG_TXIFG)); // wait till TXBUF is empty (Check TXIFG flag)
  EUSCI_A2->TXBUF = s;                          // send character through buffer
}
